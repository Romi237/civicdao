// CivicDAO Backend Tests
// Run with: cd backend && npm test
// These tests check every major API endpoint works correctly.

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-long-enough-for-testing-purposes-123';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-long-enough-for-testing-456';
process.env.MONGODB_URI = 'mongodb://localhost:27017/civicdao_test';
process.env.BCRYPT_SALT_ROUNDS = '4';

const request = require('supertest');
const app = require('../server');

const testUser = {
  name: 'Test User',
  email: `test_${Date.now()}@civicdao.org`,
  password: 'password123',
};

let authToken = '';
let refreshToken = '';
let proposalId = '';

// ── Health check ──────────────────────────────────────────────────────────────
describe('GET /health', () => {
  it('returns ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

// ── Register ──────────────────────────────────────────────────────────────────
describe('POST /api/register', () => {
  it('rejects when fields are missing', async () => {
    const res = await request(app).post('/api/register').send({ email: testUser.email });
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBeDefined();
  });

  it('rejects password shorter than 6 characters', async () => {
    const res = await request(app).post('/api/register')
      .send({ email: testUser.email, password: '123', name: 'X' });
    expect(res.statusCode).toBe(400);
  });

  it('rejects invalid email format', async () => {
    const res = await request(app).post('/api/register')
      .send({ email: 'notanemail', password: 'abc123', name: 'Test' });
    expect(res.statusCode).toBe(400);
  });

  it('creates a new user and returns a token', async () => {
    const res = await request(app).post('/api/register').send(testUser);
    expect(res.statusCode).toBe(201);
    expect(res.body.token).toBeDefined();
    expect(res.body.user.email).toBe(testUser.email);
    expect(res.body.user.role).toBe('member');
    authToken = res.body.token;
    refreshToken = res.body.refreshToken;
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
    authToken = res.body.token;
    refreshToken = res.body.refreshToken;
  });
});

// ── Refresh token ─────────────────────────────────────────────────────────────
describe('POST /api/refresh', () => {
  it('issues a new access token from a valid refresh token', async () => {
    const res = await request(app).post('/api/refresh').send({ refreshToken });
    expect(res.statusCode).toBe(200);
    expect(res.body.token).toBeDefined();
    authToken = res.body.token;
    refreshToken = res.body.refreshToken;
  });

  it('rejects a fake refresh token', async () => {
    const res = await request(app).post('/api/refresh')
      .send({ refreshToken: 'fake.token.value' });
    expect(res.statusCode).toBe(401);
  });
});

// ── Proposals ────────────────────────────────────────────────────────────────
describe('GET /api/proposals', () => {
  it('blocks unauthenticated requests', async () => {
    const res = await request(app).get('/api/proposals');
    expect(res.statusCode).toBe(401);
  });

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
        description: 'Green space for everyone',
        requestedBudget: 5000,
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

// ── 404 ───────────────────────────────────────────────────────────────────────
describe('Unknown routes', () => {
  it('returns 404 for unknown paths', async () => {
    const res = await request(app).get('/api/doesnotexist');
    expect(res.statusCode).toBe(404);
  });
});