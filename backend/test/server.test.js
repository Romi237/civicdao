
// CivicDAO Backend Tests
// Run with: cd backend && npm test
// These tests use an in-memory MongoDB for testing!

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-long-enough-for-testing-purposes-123';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-long-enough-for-testing-456';
process.env.BCRYPT_SALT_ROUNDS = '4';

const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let app;
let connectDB;
let authToken = '';
let refreshToken = '';
let proposalId = '';

const testUser = {
  name: 'Test User',
  email: `test-${Date.now()}@civicdao.org`,
  password: 'password123',
};

beforeAll(async () => {
  jest.setTimeout(60000); // Set test timeout to 60 seconds
  // Start in-memory MongoDB server
  mongoServer = await MongoMemoryServer.create();
  process.env.MONGODB_URI = mongoServer.getUri(); // Override MONGODB_URI for testing
  // Now require app.js after setting env vars
  const appModule = require('../app');
  app = appModule.app;
  connectDB = appModule.connectDB;
  // Now connect to test DB
  await connectDB();
});

afterAll(async () => {
  if (mongoose.connection.readyState === 1) {
    await mongoose.connection.dropDatabase();
    await mongoose.connection.close();
  }
  if (mongoServer) {
    await mongoServer.stop();
  }
});

// ── Health check ──────────────────────────────────────────────────────────────
describe('GET /health', () => {
  it('returns ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

// ── Proposal Categories (no auth) ─────────────────────────────────────────────
describe('GET /api/proposals/categories', () => {
  it('returns list of categories without auth', async () => {
    const res = await request(app).get('/api/proposals/categories');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body).toContain('General');
    expect(res.body).toContain('Environment');
  });
});

// ── Register ──────────────────────────────────────────────────────────────────
describe('POST /api/register', () => {
  it('creates a new user and returns a token', async () => {
    const res = await request(app).post('/api/register').send(testUser);
    expect(res.statusCode).toBe(201);
    expect(res.body.token).toBeDefined();
  });

  it('rejects duplicate email', async () => {
    const res = await request(app).post('/api/register').send(testUser);
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toMatch(/already exists/i);
  });
});

// ── Login ─────────────────────────────────────────────────────────────────────
describe('POST /api/login', () => {
  it('rejects wrong password', async () => {
    const res = await request(app).post('/api/login')
      .send({ email: testUser.email, password: 'wrongpassword' });
    expect(res.statusCode).toBe(400);
  });

  it('logs in with correct credentials', async () => {
    const res = await request(app).post('/api/login')
      .send({ email: testUser.email, password: testUser.password });
    expect(res.statusCode).toBe(200);
    expect(res.body.token).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    authToken = res.body.token;
    refreshToken = res.body.refreshToken;
  });
});

// ── Refresh Token ─────────────────────────────────────────────────────────────
describe('POST /api/refresh', () => {
  it('issues a new access token from a valid refresh token', async () => {
    const res = await request(app).post('/api/refresh').send({ refreshToken });
    expect(res.statusCode).toBe(200);
    expect(res.body.token).toBeDefined();
    authToken = res.body.token;
    refreshToken = res.body.refreshToken;
  });
});

// ── Proposals ─────────────────────────────────────────────────────────────────
describe('GET /api/proposals', () => {
  it('returns proposal list when authenticated', async () => {
    const res = await request(app).get('/api/proposals')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.proposals)).toBe(true);
  });
});

describe('POST /api/proposals', () => {
  it('rejects when title is missing', async () => {
    const res = await request(app).post('/api/proposals')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ description: 'Test', requestedBudget: 1000 });
    expect(res.statusCode).toBe(400);
  });

  it('rejects zero budget', async () => {
    const res = await request(app).post('/api/proposals')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ title: 'T', description: 'D', requestedBudget: 0 });
    expect(res.statusCode).toBe(400);
  });

  it('creates a proposal successfully', async () => {
    const res = await request(app).post('/api/proposals')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Build a park',
        description: 'Let\'s build a new park for the community',
        requestedBudget: 15000,
        category: 'Environment'
      });
    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Build a park');
    expect(res.body.status).toBe('pending');
    proposalId = res.body._id;
  });
});

// ── Voting ────────────────────────────────────────────────────────────────────
describe('POST /api/vote', () => {
  it('rejects voting on a pending (not voting) proposal', async () => {
    const res = await request(app).post('/api/vote')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ proposalId, vote: true });
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toMatch(/not open/i);
  });
});

// ── Treasury ──────────────────────────────────────────────────────────────────
describe('GET /api/treasury', () => {
  it('returns treasury data for authenticated users', async () => {
    const res = await request(app).get('/api/treasury')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.balance).toBeDefined();
    expect(Array.isArray(res.body.transactions)).toBe(true);
  });
});

