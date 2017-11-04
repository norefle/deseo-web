const Express = require("express");
const BodyParser = require("body-parser");
const Timeout = require("connect-timeout");

const Db = require(__dirname + "/db");

const API_PREFIX = "/api/v1/";
const DEFAULT_PORT = 8123;

const app = Express();
app.use(Timeout(10000));
app.use(BodyParser.json());
app.use(Express.static(__dirname + "/public"));
app.set("port", (process.env.PORT || DEFAULT_PORT));

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

app.get(api("list/:user"), (req, res) => {
    Db.list(req.params.user).then((data) => {
        res.status(200).json({ success: true, data });
    }).catch((error) => {
        res.status(404).json({ success: false, error });
    });
});

app.listen(app.get("port"), () => {
    console.info("Server running on port", app.get("port"));
});