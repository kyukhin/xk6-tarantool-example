import { check } from "k6";
import datagen from "k6/x/datagen";
import tarantool from "k6/x/tarantool";

const conn1 = tarantool.connect("172.19.0.2:3301");
const conn2 = tarantool.connect("172.19.0.3:3301");

const baseScenario = {
  executor: "constant-arrival-rate",
  rate: 10000,
  timeUnit: "1s",
  duration: "10s",
  preAllocatedVUs: 100,
  maxVUs: 100,
};

export let options = {
  scenarios: {
    conn1test: Object.assign({ exec: "conn1test" }, baseScenario),
    conn2test: Object.assign({ exec: "conn2test" }, baseScenario),
  },
  thresholds: {
    iteration_duration: ["p(95) < 100", "p(90) < 75"],
    checks: ["rate = 1"],
  },
};

export const setup = () => {
  console.log("Run data generation in the background");
  datagen.generateData();
};

export const conn1test = () => {
  const res = tarantool.call(conn1, "api_car_add", [datagen.getData()]);
  check(res, { "is status OK": (r) => r["code"] === 0 });
};

export const conn2test = () => {
  const res = tarantool.call(conn2, "api_car_add", [datagen.getData()]);
  check(res, { "is status OK": (r) => r["code"] === 0 });
};

export const teardown = () => {
  console.log("Testing complete");
};
