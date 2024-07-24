const user = args[0];
const from_date = args[1];
const to_date = args[2];

const url = `https://deep-index.moralis.io/api/v2.2/${user}/`;
if (!secrets.apiKey) {
  throw Error("api key invalid");
}

const triggerRequest = Functions.makeHttpRequest({
  url: url,
  method: "GET",
  headers: {
    Accept: "application/json",
    "x-api-key": secrets.apiKey,
  },
  params: {
    chain: "sepolia",
    from_date: from_date,
    to_date: to_date,
  },
});

const triggerResponse = await triggerRequest;
if (triggerResponse.error) {
  console.log(triggerResponse.error);
  throw Error("Request failed");
}

const data = triggerResponse["data"];
if (data.Response === "Error") {
  console.error(data.Message);
  throw Error(`Functional error. Read message: ${data.Message}`);
}

const resultData = data["result"];

let result = 1;
if (resultData.length > 0) {
  result = resultData.some((item) => item.from_address == user) ? 2 : 1;
}

return Functions.encodeUint256(result);
