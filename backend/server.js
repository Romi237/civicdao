const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose'); 
const bcrypt = require('bcryptjs'); 
const jwt = require('jsonwebtoken'); 
const rateLimit = require('express-rate-limit'); require('dotenv').config(); 

const app = express(); 
const PORT = process.env.PORT || 3000; 
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/civicdao'; 
const JWT_SECRET = process.env.JWT_SECRET; 
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET; 
const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || '12'); 
const JWT_EXPIRY = process.env.JWT_EXPIRY || '1h'; 
const REFRESH_EXPIRY = process.env.REFRESH_TOKEN_EXPIRY || '7d'; 

if (!JWT_SECRET) { 
  console.error('ERROR: JWT_SECRET not set. Run: node dds.js'); 
  process.exit(1); 
} 

if (!JWT_REFRESH_SECRET) { 
  console.error('ERROR: JWT_REFRESH_SECRET not set. Run: node dds.js'); 
  process.exit(1); 
} 

app.use(cors({ origin: process.env.CORS_ORIGIN || '*', credentials: true })); 
app.use(express.json({ limit: '10mb' })); 
app.use(express.urlencoded({ extended: true, limit: '10mb' })); 

app.use((req, _res, next) => { 
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`); 
  next(); 
}); 

const authLimit = rateLimit({ 
  windowMs: 15 * 60 * 1000, 
  max: 20, 
  message: { error: 'Too many attempts. Please wait.' }, 
  standardHeaders: true, 
  legacyHeaders: false, 
}); 

const apiLimit = rateLimit({ 
  windowMs: 15 * 60 * 1000, 
  max: 100, 
  message: { error: 'Rate limit exceeded.' }, 
}); 

app.use('/api/login', authLimit); 
app.use('/api/register', authLimit); 
app.use('/api/', apiLimit); 

mongoose.connect(MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true }) 
  .then(async () => { 
    console.log('Connected to MongoDB'); 
    await seedDelegateCandidates(); 
  }) 
  .catch(err => { 
    console.error('MongoDB error:', err.message); 
    process.exit(1); 
  }); 

const UserSchema = new mongoose.Schema({ 
  email: { type: String, unique: true, required: true }, 
  password: { type: String, required: true }, 
  name: { type: String, required: true }, 
  role: { type: String, enum: ['admin', 'member'], default: 'member' }, 
  profileRole: { type: String, default: 'Regular member' }, 
  interests: [String], 
  delegatedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'Delegate', default: null }, 
  votingPower: { type: Number, default: 1250 }, 
  joinDate: { type: Date, default: Date.now }, 
  isActive: { type: Boolean, default: true }, 
  votedProposals: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Proposal' }], 
  refreshTokens: [String], 
}); 

const ProposalSchema = new mongoose.Schema({ 
  title: { type: String, required: true }, 
  description: { type: String, required: true }, 
  requestedBudget: { type: Number, required: true }, 
  authorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, 
  authorName: { type: String, required: true }, 
  createdAt: { type: Date, default: Date.now }, 
  voteEndDate: { type: Date }, 
  status: { type: String, enum: ['pending','voting','accepted','rejected'], default: 'pending' }, 
  yesVotes: { type: Number, default: 0 }, 
  noVotes: { type: Number, default: 0 }, 
  totalVotes: { type: Number, default: 0 }, 
  category: { type: String, default: 'General' }, 
}); 

const VoteSchema = new mongoose.Schema({ 
  proposalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Proposal', required: true }, 
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, 
  vote: { type: Boolean, required: true }, 
  votedAt: { type: Date, default: Date.now }, 
}); 

VoteSchema.index({ proposalId: 1, userId: 1 }, { unique: true }); 

const DelegateSchema = new mongoose.Schema({ 
  name: { type: String, required: true }, 
  initials: { type: String, required: true }, 
  color: { type: Number, required: true }, 
  participation: { type: String, default: '0%' }, 
  delegators: { type: Number, default: 0 }, 
}); 

const NotificationSchema = new mongoose.Schema({ 
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, 
  type: { type: String, default: 'notification' }, 
  title: { type: String, required: true }, 
  body: { type: String, required: true }, 
  color: { type: Number, default: 0xFF8B5CF6 }, 
  read: { type: Boolean, default: false }, 
  createdAt: { type: Date, default: Date.now }, 
}); 

const TreasuryTxSchema = new mongoose.Schema({ 
  type: { type: String, enum: ['deposit','withdrawal','proposal_funded'], required: true }, 
  amount: { type: Number, required: true }, 
  description: { type: String, required: true }, 
  date: { type: Date, default: Date.now }, 
  proposalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Proposal' }, 
  performedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, 
}); 

const User = mongoose.model('User', UserSchema); 
const Proposal = mongoose.model('Proposal', ProposalSchema); 
const Vote = mongoose.model('Vote', VoteSchema); 
const Delegate = mongoose.model('Delegate', DelegateSchema); 
const Notification = mongoose.model('Notification', NotificationSchema); 
const Treasury = mongoose.model('TreasuryTransaction', TreasuryTxSchema); 

async function seedDelegateCandidates() { 
  const count = await Delegate.countDocuments(); 
  if (count > 0) return; 
  await Delegate.create([ 
    { 
      name: 'James Kimani', 
      initials: 'JK', 
      color: 0xFF10B981, 
      participation: '91%', 
      delegators: 3, 
    }, 
    { 
      name: 'Sofia Ferreira', 
      initials: 'SF', 
      color: 0xFFEC4899, 
      participation: '78%', 
      delegators: 1, 
    }, 
    { 
      name: 'Nadia Benali', 
      initials: 'NB', 
      color: 0xFFF59E0B, 
      participation: '62%', 
      delegators: 0, 
    }, 
  ]); 
} 

const validEmail = (e) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e); 
const validPassword = (p) => typeof p === 'string' && p.length >= 6; 

const toSafeUser = (u) => ({ 
  id: u._id, 
  email: u.email, 
  name: u.name, 
  role: u.role, 
  joinDate: u.joinDate, 
  isActive: u.isActive, 
  votedProposals: u.votedProposals, 
}); 

const issueTokens = (user) => { 
  const payload = { id: user._id, email: user.email, role: user.role }; 
  return { 
    access: jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRY }), 
    refresh: jwt.sign(payload, JWT_REFRESH_SECRET, { expiresIn: REFRESH_EXPIRY }), 
  }; 
}; 

const auth = (req, res, next) => { 
  const token = req.headers.authorization?.split(' ')[1]; 
  if (!token) return res.status(401).json({ error: 'No token provided.' }); 
  try { 
    req.user = jwt.verify(token, JWT_SECRET); 
    next(); 
  } catch { 
    res.status(401).json({ error: 'Token invalid or expired.' }); 
  } 
}; 

const adminOnly = (req, res, next) => 
  req.user?.role === 'admin' ? next() : res.status(403).json({ error: 'Admin only.' }); 

app.get('/health', (_req, res) => 
  res.json({ status: 'ok', db: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected', uptime: Math.round(process.uptime()) }) 
); 

app.get('/metrics', async (_req, res) => { 
  try { 
    const [users, proposals, votes, active] = await Promise.all([ 
      User.countDocuments(), 
      Proposal.countDocuments(), 
      Vote.countDocuments(), 
      Proposal.countDocuments({ status: 'voting' }), 
    ]); 
    res.set('Content-Type', 'text/plain'); 
    res.send([ 
      `civicdao_users_total ${users}`, 
      `civicdao_proposals_total ${proposals}`, 
      `civicdao_active_proposals ${active}`, 
      `civicdao_votes_total ${votes}`, 
      `civicdao_uptime_seconds ${Math.round(process.uptime())}`, 
    ].join('\n')); 
  } catch { 
    res.status(500).send('# metrics error'); 
  } 
}); 

app.post('/api/register', async (req, res) => { 
  try { 
    const { email, password, name } = req.body; 
    if (!email || !password || !name) return res.status(400).json({ error: 'All fields are required.' }); 
    if (!validEmail(email)) return res.status(400).json({ error: 'Invalid email.' }); 
    if (!validPassword(password)) return res.status(400).json({ error: 'Password must be at least 6 characters.' }); 
    if (name.trim().length < 2) return res.status(400).json({ error: 'Name must be at least 2 characters.' }); 
    if (await User.findOne({ email: email.toLowerCase() })) return res.status(400).json({ error: 'An account with that email already exists.' }); 

    const user = await User.create({ 
      email: email.toLowerCase().trim(), 
      password: await bcrypt.hash(password, BCRYPT_ROUNDS), 
      name: name.trim(), 
    }); 

    const { access, refresh } = issueTokens(user); 
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: refresh } }); 

    res.status(201).json({ token: access, refreshToken: refresh, user: toSafeUser(user) }); 
  } catch (err) { 
    console.error(err); 
    res.status(500).json({ error: 'Server error.' }); 
  } 
}); 

app.post('/api/login', async (req, res) => { 
  try { 
    const { email, password } = req.body; 
    if (!email || !password) return res.status(400).json({ error: 'Email and password required.' }); 
    const user = await User.findOne({ email: email.toLowerCase() }); 
    if (!user || !(await bcrypt.compare(password, user.password))) return res.status(400).json({ error: 'Invalid email or password.' }); 
    if (!user.isActive) return res.status(403).json({ error: 'Account suspended.' }); 

    const { access, refresh } = issueTokens(user); 
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: refresh } }); 

    res.json({ token: access, refreshToken: refresh, user: toSafeUser(user) }); 
  } catch (err) { 
    console.error(err); 
    res.status(500).json({ error: 'Server error.' }); 
  } 
}); 

app.post('/api/refresh', async (req, res) => { 
  const { refreshToken } = req.body; 
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token required.' }); 
  try { 
    const payload = jwt.verify(refreshToken, JWT_REFRESH_SECRET); 
    const user = await User.findById(payload.id); 
    if (!user || !user.refreshTokens.includes(refreshToken)) return res.status(401).json({ error: 'Invalid refresh token.' }); 

    await User.findByIdAndUpdate(user._id, { $pull: { refreshTokens: refreshToken } }); 
    const { access, refresh: newRefresh } = issueTokens(user); 
    await User.findByIdAndUpdate(user._id, { $push: { refreshTokens: newRefresh } }); 

    res.json({ token: access, refreshToken: newRefresh }); 
  } catch { 
    res.status(401).json({ error: 'Refresh token expired.' }); 
  } 
}); 

app.post('/api/logout', auth, async (req, res) => { 
  const { refreshToken } = req.body; 
  if (refreshToken) await User.findByIdAndUpdate(req.user.id, { $pull: { refreshTokens: refreshToken } }); 
  res.json({ message: 'Logged out.' }); 
}); 

app.get('/api/proposals', auth, async (req, res) => { 
  try { 
    const { status, page = 1, limit = 20 } = req.query; 
    const filter = status ? { status } : {}; 
    const [proposals, total] = await Promise.all([ 
      Proposal.find(filter).sort({ createdAt: -1 }).skip((page - 1) * Number(limit)).limit(Number(limit)), 
      Proposal.countDocuments(filter), 
    ]); 
    res.json({ proposals, total, page: Number(page) }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/proposals/:id', auth, async (req, res) => { 
  try { 
    const p = await Proposal.findById(req.params.id); 
    if (!p) return res.status(404).json({ error: 'Proposal not found.' }); 
    res.json(p); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/proposals', auth, async (req, res) => { 
  try { 
    const { title, description, requestedBudget, voteEndDate, category } = req.body; 
    if (!title || !description || requestedBudget == null) return res.status(400).json({ error: 'Title, description and budget are required.' }); 
    if (Number(requestedBudget) <= 0) return res.status(400).json({ error: 'Budget must be greater than zero.' }); 

    const user = await User.findById(req.user.id); 
    const proposal = await Proposal.create({ 
      title: title.trim(), 
      description: description.trim(), 
      requestedBudget: Number(requestedBudget), 
      authorId: user._id, 
      authorName: user.name, 
      voteEndDate: voteEndDate ? new Date(voteEndDate) : null, 
      category: category || 'General', 
    }); 

    res.status(201).json(proposal); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.put('/api/proposals/:id/status', auth, adminOnly, async (req, res) => { 
  try { 
    const { status } = req.body; 
    const valid = ['pending','voting','accepted','rejected']; 
    if (!valid.includes(status)) return res.status(400).json({ error: 'Invalid status.' }); 

    const p = await Proposal.findByIdAndUpdate(req.params.id, { status }, { new: true }); 
    if (!p) return res.status(404).json({ error: 'Proposal not found.' }); 
    res.json(p); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/vote', auth, async (req, res) => { 
  try { 
    const { proposalId, vote } = req.body; 
    if (!proposalId || vote === undefined) return res.status(400).json({ error: 'proposalId and vote required.' }); 

    const proposal = await Proposal.findById(proposalId); 
    if (!proposal) return res.status(404).json({ error: 'Proposal not found.' }); 
    if (proposal.status !== 'voting') return res.status(400).json({ error: 'Not open for voting.' }); 
    if (await Vote.findOne({ proposalId, userId: req.user.id })) return res.status(400).json({ error: 'Already voted.' }); 

    await Vote.create({ proposalId, userId: req.user.id, vote }); 

    if (vote) proposal.yesVotes += 1; else proposal.noVotes += 1; 
    proposal.totalVotes += 1; 
    await proposal.save(); 

    await User.findByIdAndUpdate(req.user.id, { $addToSet: { votedProposals: proposalId } }); 

    res.json({ success: true, proposal }); 
  } catch (err) { 
    if (err.code === 11000) return res.status(400).json({ error: 'Already voted.' }); 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/treasury', auth, async (req, res) => { 
  try { 
    const [recent, all, totalProposals, activeProposals, totalMembers] = await Promise.all([ 
      Treasury.find().sort({ date: -1 }).limit(20), 
      Treasury.find(), 
      Proposal.countDocuments(), 
      Proposal.countDocuments({ status: 'voting' }), 
      User.countDocuments({ isActive: true }), 
    ]); 

    let balance = 0; 
    for (const tx of all) { 
      if (tx.type === 'deposit') balance += tx.amount; 
      else balance -= tx.amount; 
    } 

    res.json({ balance, transactions: recent, totalProposals, activeProposals, totalMembers }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/treasury', auth, adminOnly, async (req, res) => { 
  try { 
    const { type, amount, description } = req.body; 
    const valid = ['deposit','withdrawal','proposal_funded']; 
    if (!valid.includes(type)) return res.status(400).json({ error: 'Invalid type.' }); 
    if (!amount || Number(amount) <= 0) return res.status(400).json({ error: 'Amount must be positive.' }); 
    if (!description) return res.status(400).json({ error: 'Description required.' }); 

    const tx = await Treasury.create({ type, amount: Number(amount), description, performedBy: req.user.id }); 
    res.status(201).json(tx); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

// Allow any authenticated member to view the member directory.
app.get('/api/users', auth, async (req, res) => { 
  try { 
    const users = await User.find().select('-password -refreshTokens').sort({ joinDate: -1 }); 
    res.json(users); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/users/me', auth, async (req, res) => { 
  try { 
    const user = await User.findById(req.user.id).select('-password -refreshTokens'); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    res.json(toSafeUser(user)); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/delegates', auth, async (req, res) => { 
  try { 
    const [delegates, user] = await Promise.all([ 
      Delegate.find().sort({ name: 1 }), 
      User.findById(req.user.id).populate('delegatedTo'), 
    ]); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    res.json({ 
      votingPower: user.votingPower ?? 1250, 
      delegatedTo: user.delegatedTo ? user.delegatedTo._id : null, 
      delegates, 
      currentDelegateName: user.delegatedTo ? user.delegatedTo.name : null, 
    }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/delegates/:id', auth, async (req, res) => { 
  try { 
    const delegate = await Delegate.findById(req.params.id); 
    if (!delegate) return res.status(404).json({ error: 'Delegate not found.' }); 
    const user = await User.findById(req.user.id); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    const previous = user.delegatedTo ? user.delegatedTo.toString() : null; 
    if (previous === delegate._id.toString()) { 
      return res.json({ success: true, delegatedTo: delegate._id }); 
    } 
    user.delegatedTo = delegate._id; 
    await user.save(); 
    if (previous) { 
      await Delegate.findByIdAndUpdate(previous, { $inc: { delegators: -1 } }); 
    } 
    await Delegate.findByIdAndUpdate(delegate._id, { $inc: { delegators: 1 } }); 
    res.json({ success: true, delegatedTo: delegate._id }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/delegates/revoke', auth, async (req, res) => { 
  try { 
    const user = await User.findById(req.user.id); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    const previous = user.delegatedTo ? user.delegatedTo.toString() : null; 
    if (!previous) return res.json({ success: true }); 
    user.delegatedTo = null; 
    await user.save(); 
    await Delegate.findByIdAndUpdate(previous, { $inc: { delegators: -1 } }); 
    res.json({ success: true }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/notifications', auth, async (req, res) => { 
  try { 
    const userId = req.user.id; 
    const notifications = await Notification.find({ userId }).sort({ createdAt: -1 }); 
    res.json(notifications); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/notifications/mark-read', auth, async (req, res) => { 
  try { 
    const userId = req.user.id; 
    const ids = Array.isArray(req.body.ids) ? req.body.ids : []; 
    const filter = { userId }; 
    if (ids.length) filter._id = { $in: ids }; 
    await Notification.updateMany(filter, { read: true }); 
    res.json({ success: true }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.get('/api/onboarding/options', auth, async (req, res) => { 
  try { 
    res.json({ 
      roles: [ 
        { 
          id: 'regular', 
          icon: 'person_outline_rounded', 
          title: 'Regular member', 
          desc: 'I vote on proposals and participate', 
          color: 0xFF8B5CF6, 
        }, 
        { 
          id: 'council', 
          icon: 'star_outline_rounded', 
          title: 'Council member', 
          desc: 'I help govern and create proposals', 
          color: 0xFFF59E0B, 
        }, 
        { 
          id: 'observer', 
          icon: 'visibility_outlined', 
          title: 'Observer', 
          desc: 'I monitor activity without voting', 
          color: 0xFF22C55E, 
        }, 
      ], 
      interests: [ 
        'Treasury', 
        'Governance', 
        'Events', 
        'Partnerships', 
        'Technical', 
        'Community', 
      ], 
    }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.post('/api/onboarding/complete', auth, async (req, res) => { 
  try { 
    const { role, interests } = req.body; 
    const user = await User.findById(req.user.id); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    if (typeof role === 'string') user.profileRole = role; 
    if (Array.isArray(interests)) user.interests = interests; 
    await user.save(); 
    res.json({ success: true }); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

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

app.put('/api/users/:id/suspend', auth, adminOnly, async (req, res) => { 
  try { 
    if (String(req.params.id) === String(req.user.id)) return res.status(400).json({ error: 'Cannot suspend yourself.' }); 
    const user = await User.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true }).select('-password -refreshTokens'); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    res.json(user); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.put('/api/users/:id/reactivate', auth, adminOnly, async (req, res) => { 
  try { 
    const user = await User.findByIdAndUpdate(req.params.id, { isActive: true }, { new: true }).select('-password -refreshTokens'); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    res.json(user); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.put('/api/users/:id/promote', auth, adminOnly, async (req, res) => { 
  try { 
    const user = await User.findByIdAndUpdate(req.params.id, { role: 'admin' }, { new: true }).select('-password -refreshTokens'); 
    if (!user) return res.status(404).json({ error: 'User not found.' }); 
    res.json(user); 
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  } 
}); 

app.use((_req, res) => res.status(404).json({ error: 'Route not found.' })); 

if (require.main === module) {
  app.listen(PORT, () => console.log(`CivicDAO API running on port ${PORT}`)); 
}

module.exports = app;