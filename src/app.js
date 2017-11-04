const Express = require('express');
const BodyParser = require('body-parser');
const Timeout = require('connect-timeout');

const API_PREFIX = "/api/v1/";
const DEFAULT_ADDRES = "127.0.0.1";
const DEFAULT_PORT = 8123;

const app = Express();
app.use(Timeout(10000));
app.use(BodyParser.json());
app.use(Express.static('src/static'));

function api(postfix) {
    return API_PREFIX + postfix;
}

function describe(endpoint, description) {
    return {
        endpoint: api(endpoint)
        , description
    };
}

app.get(api("help"), (req, res) => {
    res.status(200).json({
        endpoints: [
            describe("help", "Describes all available endpoints")
        ]
    });
});

app.listen(DEFAULT_PORT, DEFAULT_ADDRES, () => {
    console.info(`Server running at: ${DEFAULT_ADDRES}:${DEFAULT_PORT}`);
});