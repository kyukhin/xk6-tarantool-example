import datagen from "k6/x/datagen";
import tarantool from "k6/x/tarantool";

const conn = tarantool.connect("172.19.0.2:3301");

export let options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      rate: 1000000,
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 500,
      maxVUs: 1000,
    },
  },
};

export const setup = () => {
  console.log("Run data generation");
  datagen.generateData();
};

export default () => {
  tarantool.call(conn, "api_car_add", [datagen.getData()]);
};

export const teardown = () => {
  console.log("Testing complete");
};
