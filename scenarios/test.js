import datagen from "k6/x/datagen";
import tarantool from "k6/x/tarantool";

const conn1 = tarantool.connect("172.19.0.2:3301");
const conn2 = tarantool.connect("172.19.0.3:3301");

export let options = {
  scenarios: {
    conn1test: {
      executor: "constant-arrival-rate",
      rate: 10000,
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 100,
      maxVUs: 100,
      exec: "conn1test",
    },
    conn2test: {
      executor: "constant-arrival-rate",
      rate: 10000,
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 100,
      maxVUs: 100,
      exec: "conn2test",
    },
  },
};

export const setup = () => {
  console.log("Run data generation in the background");
  datagen.generateData();
};

export const conn1test = () => {
  tarantool.call(conn1, "api_car_add", [datagen.getData()]);
};

export const conn2test = () => {
  tarantool.call(conn2, "api_car_add", [datagen.getData()]);
};

export const teardown = () => {
  console.log("Testing complete");
};
