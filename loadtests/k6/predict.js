import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: __ENV.K6_VUS ? parseInt(__ENV.K6_VUS) : 10,
  duration: __ENV.K6_DURATION || '30s',
  thresholds: {
    http_req_duration: ['p(95)<500'],
    'http_req_failed': ['rate<0.01']
  }
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

const examplePayload = {
  "gender": "M",
  "region": "East Anglian Region",
  "highest_education": "HE Qualification",
  "imd_band": "90-100%",
  "age_band": "35-55",
  "num_of_prev_attempts": 0,
  "studied_credits": 240,
  "disability": "N",
  "avg_score": 75.5,
  "num_assessments": 5
};

export default function () {
  // Check root/health
  let res = http.get(`${BASE_URL}/`);
  check(res, {
    'home status 200': (r) => r.status === 200,
    'home has message': (r) => r.json && r.json().message !== undefined
  });

  // Check model-info
  let info = http.get(`${BASE_URL}/model-info`);
  check(info, {
    'model-info 200': (r) => r.status === 200
  });

  // POST /predict
  let headers = { 'Content-Type': 'application/json' };
  let pred = http.post(`${BASE_URL}/predict`, JSON.stringify(examplePayload), { headers: headers });
  check(pred, {
    'predict status 200': (r) => r.status === 200,
    'predict returned something': (r) => {
      try {
        const body = r.json();
        return body && (body.success === true || body.prediction !== undefined);
      } catch (e) {
        return false;
      }
    }
  });

  // small pause between iterations
  sleep(1);
}
