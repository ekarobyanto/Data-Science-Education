// CAUTION: Hitting /train will retrain the ML model which may be CPU and IO intensive.
// Use this script only intentionally and with low load (single VU, short duration).

import http from 'k6/http';
import { check } from 'k6';

export let options = {
  vus: 1,
  duration: '10s'
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

export default function () {
  let res = http.post(`${BASE_URL}/train`);
  check(res, {
    'train status 200': (r) => r.status === 200
  });
}
