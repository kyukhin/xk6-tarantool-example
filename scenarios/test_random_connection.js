import datagen from "k6/x/datagen";
import tarantool from "k6/x/tarantool";

const conn1 = tarantool.connect("172.19.0.2:3301");
const conn2 = tarantool.connect("172.19.0.3:3301");

const conns = [conn1, conn2];

const getRandomConn = () => conns[Math.floor(Math.random() * conns.length)];

export let options = {
  scenarios: {
    conntest: {
      executor: "constant-arrival-rate",
      rate: 10000,
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 100,
      maxVUs: 100,
    },
  },
};

export const setup = () => {
  console.log("Run data generation in the background");
  datagen.generateData();
};

export default function () {
  tarantool.call(getRandomConn(), "api_car_add", [datagen.getData()]);
}

export const teardown = () => {
  console.log("Testing complete");
};
