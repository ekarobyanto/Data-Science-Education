import http from 'k6/http';
import { check } from 'k6';

// This script uses a constant-arrival-rate executor to simulate a realistic
// request-per-second (RPS) pattern instead of a fixed number of VUs.
// This is useful for testing how the API handles a target throughput.

export let options = {
  scenarios: {
    constant_rps: {
      executor: 'constant-arrival-rate',
      rate: __ENV.K6_RATE ? parseInt(__ENV.K6_RATE) : 50, // target RPS
      timeUnit: '1s',
      duration: __ENV.K6_DURATION || '1m',
      preAllocatedVUs: __ENV.K6_PRE_ALLOCATED_VUS ? parseInt(__ENV.K6_PRE_ALLOCATED_VUS) : 10,
      maxVUs: __ENV.K6_MAX_VUS ? parseInt(__ENV.K6_MAX_VUS) : 100
    }
  },
  thresholds: {
    http_req_duration: ['p(95)<800', 'p(99)<1500'],
    'http_req_failed': ['rate<0.05'],
    'checks': ['rate>0.95']
  }
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

// Possible values for categorical fields
const genders = ['M', 'F'];
const regions = [
  'East Anglian Region',
  'Scotland',
  'North Western Region',
  'South East Region',
  'West Midlands Region',
  'Wales',
  'Yorkshire Region',
  'North Region',
  'South Region',
  'London Region',
  'East Midlands Region',
  'South West Region'
];
const educationLevels = [
  'HE Qualification',
  'A Level or Equivalent',
  'Lower Than A Level',
  'Post Graduate Qualification',
  'No Formal quals'
];
const imdBands = [
  '0-10%', '10-20%', '20-30%', '30-40%', '40-50%',
  '50-60%', '60-70%', '70-80%', '80-90%', '90-100%'
];
const ageBands = ['0-35', '35-55', '55<='];
const disabilities = ['Y', 'N'];

function randomChoice(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomFloat(min, max) {
  return Math.random() * (max - min) + min;
}

function generateRandomPayload() {
  return {
    gender: randomChoice(genders),
    region: randomChoice(regions),
    highest_education: randomChoice(educationLevels),
    imd_band: randomChoice(imdBands),
    age_band: randomChoice(ageBands),
    num_of_prev_attempts: randomInt(0, 6),
    studied_credits: randomChoice([60, 120, 180, 240, 300]),
    disability: randomChoice(disabilities),
    avg_score: parseFloat(randomFloat(0, 100).toFixed(2)),
    num_assessments: randomInt(1, 20)
  };
}

export default function () {
  const payload = generateRandomPayload();
  
  let headers = { 'Content-Type': 'application/json' };
  let res = http.post(`${BASE_URL}/predict`, JSON.stringify(payload), { headers: headers });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response has prediction': (r) => {
      try {
        const body = r.json();
        return body && body.prediction !== undefined;
      } catch (e) {
        return false;
      }
    },
    'response time OK': (r) => r.timings.duration < 1000
  });
}
