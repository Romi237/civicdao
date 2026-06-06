
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const swaggerUi = require("swagger-ui-express");
const YAML = require("yamljs");
const rateLimit = require('express-rate-limit');
require('dotenv').config();
const client = require('prom-client');

const app = express();
app.set('trust proxy', true);
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;
const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || '12');
const JWT_EXPIRY = process.env.JWT_EXPIRY || '1h';
const REFRESH_EXPIRY = process.env.REFRESH_TOKEN_EXPIRY || '7d';
let swaggerDocument;

try {
  swaggerDocument = YAML.load("./swagger.yaml");
} catch (e) {
  console.warn("Swagger file not found, skipping swagger setup");
}

client.collectDefaultMetrics();

const totalUsers = new client.Gauge({
  name: 'civicdao_users_total',
  help: 'Total registered users'
});

const totalProposals = new client.Gauge({
  name: 'civicdao_proposals_total',
  help: 'Total proposals'
});

const totalVotes = new client.Gauge({
  name: 'civicdao_votes_total',
  help: 'Total votes'
});

if (process.env.NODE_ENV !== 'test' && !JWT_SECRET) {
  console.error('ERROR: JWT_SECRET not set. Set JWT_SECRET in backend/.env or environment variables.');
  process.exit(1);
}

if (process.env.NODE_ENV !== 'test' && !JWT_REFRESH_SECRET) {
  console.error('ERROR: JWT_REFRESH_SECRET not set. Set JWT_REFRESH_SECRET in backend/.env or environment variables.');
  process.exit(1);
}

app.use(cors({ origin: process.env.CORS_ORIGIN || '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

const helmet = require("helmet");

app.use(
  helmet({
    contentSecurityPolicy: false,
  })
);

if (swaggerDocument) {
  app.get('/swagger-json', (req, res) => {
    res.json(swaggerDocument);
  });

  app.get('/swagger-test', (req, res) => {
    res.send('swagger route works');
  });

  console.log("Loading Swagger...");
  app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerDocument)
  );
}

app.get('/api/proposals/categories', async (req, res) => {
  try {
    res.json([
      'General',
      'Infrastructure',
      'Education',
      'Health',
      'Environment',
      'Finance',
      'Social',
      'Technology',
    ]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', async (req, res) => {
  try {
    let dbStatus = 'disconnected';
    if (mongoose.connection.readyState === 1) {
      dbStatus = 'connected';
    }
    res.status(200).json({
      status: 'ok',
      db: dbStatus,
      version: '1.0.0'
    });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// --- Mongoose Models ---
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['admin', 'member'], default: 'member' },
  profileRole: { type: String, default: '' },
  interests: [{ type: String }],
  delegatedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'Delegate' },
  votingPower: { type: Number, default: 1 },
  joinDate: { type: Date, default: Date.now },
  isActive: { type: Boolean, default: true },
  votedProposals: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Proposal' }],
  refreshTokens: [String]
});
const User = mongoose.model('User', UserSchema);

const DelegateSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  bio: String,
  proposalsCount: { type: Number, default: 0 },
  votesCount: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});
const Delegate = mongoose.model('Delegate', DelegateSchema);

const ProposalSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  requestedBudget: { type: Number, required: true, min: 0 },
  authorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  authorName: String,
  createdAt: { type: Date, default: Date.now },
  voteEndDate: Date,
  status: {
    type: String,
    enum: ['pending', 'voting', 'accepted', 'rejected'],
    default: 'pending'
  },
  yesVotes: { type: Number, default: 0 },
  noVotes: { type: Number, default: 0 },
  totalVotes: { type: Number, default: 0 },
  category: String
});
const Proposal = mongoose.model('Proposal', ProposalSchema);

const TreasurySchema = new mongoose.Schema({
  balance: { type: Number, default: 100000 },
  transactions: [
    {
      amount: Number,
      type: { type: String, enum: ['deposit', 'withdraw', 'proposal_fund'] },
      description: String,
      date: { type: Date, default: Date.now }
    }
  ]
});
const Treasury = mongoose.model('Treasury', TreasurySchema);

const NotificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  message: String,
  type: { type: String, enum: ['info', 'success', 'warning', 'error'], default: 'info' },
  read: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});
const Notification = mongoose.model('Notification', NotificationSchema);

// --- Helper Functions ---
const toSafeUser = (user) => {
  const { password, refreshTokens, ...safe } = user.toObject();
  return safe;
};

// --- Auth Middleware ---
const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    req.user = user;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Unauthorized' });
  }
};

const adminMiddleware = async (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden: Admin only' });
  }
  next();
};

// --- Rate Limiting ---
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  validate: false,
  message: { error: 'Too many login attempts, please try again later.' }
});
const apiLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  validate: false,
  message: { error: 'Too many requests, please try again later.' }
});
app.use('/api/login', loginLimiter);
app.use('/api/register', loginLimiter);
app.use('/api/', apiLimit);

// --- Seed Functions ---
const seedTreasury = async () => {
  const existing = await Treasury.findOne();
  if (!existing) {
    await Treasury.create({ balance: 100000 });
    console.log("Treasury initialized");
  }
};

const seedDelegateCandidates = async () => {
  const existing = await Delegate.countDocuments();
  if (existing === 0) {
    console.log("No delegate candidates, skipping seed");
  }
};

const seedAdminUser = async () => {
  const adminExists = await User.findOne({ email: 'admin@civicdao.org' });
  if (!adminExists) {
    const hashedPassword = await bcrypt.hash('admin123', 10);
    await User.create({
      name: 'Admin',
      email: 'admin@civicdao.org',
      password: hashedPassword,
      role: 'admin'
    });
    console.log("Admin user seeded: admin@civicdao.org / admin123");
  }
};

// --- Routes ---

// Register
app.post('/api/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    const hashedPassword = await bcrypt.hash(password, BCRYPT_ROUNDS);
    const user = await User.create({ name, email, password: hashedPassword });
    const access = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
    const refresh = jwt.sign({ userId: user._id }, JWT_REFRESH_SECRET, { expiresIn: REFRESH_EXPIRY });
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: refresh } });
    totalUsers.inc(1);
    res.status(201).json({ token: access, refreshToken: refresh, user: toSafeUser(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error.' });
  }
});

// Login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    const access = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
    const refresh = jwt.sign({ userId: user._id }, JWT_REFRESH_SECRET, { expiresIn: REFRESH_EXPIRY });
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: refresh } });
    res.json({ token: access, refreshToken: refresh, user: toSafeUser(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error.' });
  }
});

// Refresh token
app.post('/api/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }
    const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET);
    const user = await User.findOne({ _id: decoded.userId, refreshTokens: refreshToken });
    if (!user) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
    await User.findByIdAndUpdate(user._id, { $pull: { refreshTokens: refreshToken } });
    const newAccess = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
    const newRefresh = jwt.sign({ userId: user._id }, JWT_REFRESH_SECRET, { expiresIn: REFRESH_EXPIRY });
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: newRefresh } });
    res.json({ token: newAccess, refreshToken: newRefresh, user: toSafeUser(user) });
  } catch (err) {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

// Logout
app.post('/api/logout', authMiddleware, async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    const refreshToken = req.body.refreshToken;
    await User.findByIdAndUpdate(req.user._id, { $pull: { refreshTokens: refreshToken } });
    res.json({ message: 'Logged out' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get current user
app.get('/api/users/me', authMiddleware, async (req, res) => {
  res.json({ user: toSafeUser(req.user) });
});

// List users (admin)
app.get('/api/users', authMiddleware, adminMiddleware, async (req, res) => {
  const users = await User.find().select('-password -refreshTokens');
  res.json({ users });
});

// Suspend user (admin)
app.put('/api/users/:id/suspend', authMiddleware, adminMiddleware, async (req, res) => {
  await User.findByIdAndUpdate(req.params.id, { isActive: false });
  res.json({ message: 'User suspended' });
});

// Reactivate user (admin)
app.put('/api/users/:id/reactivate', authMiddleware, adminMiddleware, async (req, res) => {
  await User.findByIdAndUpdate(req.params.id, { isActive: true });
  res.json({ message: 'User reactivated' });
});

// Promote user to admin
app.put('/api/users/:id/promote', authMiddleware, adminMiddleware, async (req, res) => {
  await User.findByIdAndUpdate(req.params.id, { role: 'admin' });
  res.json({ message: 'User promoted to admin' });
});

// Get all proposals
app.get('/api/proposals', authMiddleware, async (req, res) => {
  const statusFilter = req.query.status ? { status: req.query.status } : {};
  const proposals = await Proposal.find(statusFilter).sort({ createdAt: -1 });
  res.json({ proposals });
});

// Get one proposal
app.get('/api/proposals/:id', authMiddleware, async (req, res) => {
  const proposal = await Proposal.findById(req.params.id);
  if (!proposal) {
    return res.status(404).json({ error: 'Proposal not found' });
  }
  res.json({ proposal });
});

// Create proposal
app.post('/api/proposals', authMiddleware, async (req, res) => {
  try {
    const { title, description, requestedBudget, category, voteEndDate } = req.body;
    if (!title || !description || requestedBudget == null || requestedBudget <= 0) {
      return res.status(400).json({ error: 'Title, description, and positive budget required' });
    }
    const proposal = await Proposal.create({
      title,
      description,
      requestedBudget,
      category,
      authorId: req.user._id,
      authorName: req.user.name,
      voteEndDate: voteEndDate ? new Date(voteEndDate) : undefined
    });
    totalProposals.inc(1);
    res.status(201).json(proposal);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update proposal status (admin)
app.put('/api/proposals/:id/status', authMiddleware, adminMiddleware, async (req, res) => {
  const { status } = req.body;
  const updateData = { status };
  if (status === 'voting') {
    updateData.voteEndDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  }
  const proposal = await Proposal.findByIdAndUpdate(req.params.id, updateData, { new: true });
  res.json({ proposal });
});

// Vote on proposal
app.post('/api/vote', authMiddleware, async (req, res) => {
  try {
    const { proposalId, vote } = req.body;
    const proposal = await Proposal.findById(proposalId);
    if (!proposal || proposal.status !== 'voting') {
      return res.status(400).json({ error: 'Proposal not open for voting' });
    }
    if (req.user.votedProposals.includes(proposalId)) {
      return res.status(400).json({ error: 'Already voted' });
    }
    await User.findByIdAndUpdate(req.user._id, { $push: { votedProposals: proposalId } });
    let updatedProposal;
    if (vote) {
      updatedProposal = await Proposal.findByIdAndUpdate(proposalId, { $inc: { yesVotes: 1, totalVotes: 1 } }, { new: true });
    } else {
      updatedProposal = await Proposal.findByIdAndUpdate(proposalId, { $inc: { noVotes: 1, totalVotes: 1 } }, { new: true });
    }
    totalVotes.inc(1);
    res.json({ proposal: updatedProposal });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get treasury
app.get('/api/treasury', authMiddleware, async (req, res) => {
  let treasury = await Treasury.findOne();
  if (!treasury) {
    treasury = await Treasury.create({ balance: 100000 });
  }
  res.json({
    balance: treasury.balance,
    transactions: treasury.transactions
  });
});

// Treasury transaction (admin)
app.post('/api/treasury', authMiddleware, adminMiddleware, async (req, res) => {
  const { amount, type, description } = req.body;
  const treasury = await Treasury.findOne();
  let newBalance = treasury.balance;
  if (type === 'deposit') {
    newBalance += amount;
  } else {
    newBalance -= amount;
  }
  await Treasury.findByIdAndUpdate(treasury._id, {
    balance: newBalance,
    $push: {
      transactions: { amount, type, description }
    }
  });
  res.json({ message: 'Transaction recorded' });
});

// Delegate routes
app.get('/api/delegates', authMiddleware, async (req, res) => {
  const delegates = await Delegate.find().populate('user', '-password -refreshTokens');
  res.json({ delegates });
});

app.post('/api/delegates', authMiddleware, async (req, res) => {
  const existing = await Delegate.findOne({ user: req.user._id });
  if (existing) {
    return res.status(400).json({ error: 'Already a delegate' });
  }
  const delegate = await Delegate.create({ user: req.user._id, bio: req.body.bio });
  res.json({ delegate });
});

app.post('/api/delegate', authMiddleware, async (req, res) => {
  const { delegateId } = req.body;
  await User.findByIdAndUpdate(req.user._id, { delegatedTo: delegateId });
  res.json({ message: 'Delegation set' });
});

// Notifications
app.get('/api/notifications', authMiddleware, async (req, res) => {
  const notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });
  res.json({ notifications });
});

app.put('/api/notifications/:id/read', authMiddleware, async (req, res) => {
  await Notification.findByIdAndUpdate(req.params.id, { read: true });
  res.json({ message: 'Notification marked as read' });
});

// Onboarding
app.get('/api/onboarding/options', authMiddleware, async (req, res) => {
  res.json({
    roles: ['Developer', 'Designer', 'Manager', 'Community Member', 'Other'],
    interests: ['Technology', 'Education', 'Environment', 'Social', 'Finance', 'Health']
  });
});

app.post('/api/onboarding/complete', authMiddleware, async (req, res) => {
  await User.findByIdAndUpdate(req.user._id, {
    profileRole: req.body.profileRole,
    interests: req.body.interests
  });
  res.json({ message: 'Onboarding complete' });
});

// Prometheus metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

module.exports = {
  app,
  connectDB: async () => {
    if (mongoose.connection.readyState === 1) return;
    const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/civicdao';
    await mongoose.connect(MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('Connected to MongoDB');
    await seedTreasury();
    await seedDelegateCandidates();
    await seedAdminUser();
  },
  models: { User, Proposal, Treasury, Delegate, Notification }
};

