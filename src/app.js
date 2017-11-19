const Express = require("express");
const BodyParser = require("body-parser");
const Timeout = require("connect-timeout");
const Request = require("request-promise-native");

if (process.env.NODE_ENV !== "production") {
    console.log("Loading dev environment...");
    require("dotenv").config();
}

const Db = require(__dirname + "/db");

const API_PREFIX = "/api/v1/";
const DEFAULT_PORT = 8123;

const app = Express();
app.use(Timeout(10000));
app.use(BodyParser.json());
app.use(Express.static(__dirname + "/public"));
app.set("port", (process.env.PORT || DEFAULT_PORT));
app.all("*", trace);

function trace(request, response, next) {
    console.info(request.method, request.url, request.query, request.body);
    next();
}

function api(postfix) {
    return API_PREFIX + postfix;
}

function handle(request, response, action) {
    action.then((data) => {
        console.info(request.method, request.url, "200: Ok");
        response.status(200).json({ success: true, data });
    }).catch((error) => {
        console.error(request.method, request.url, "404: ", error);
        response.status(404).json({ success: false, error });
    });
}

app.get(api("list/:user"), (request, response) => {
    return handle(
        request
        , response
        , Db.listItems(request.params.user)
    );
});

app.post(api("list/:user"), (request, response) => {
    let amazon = /^(?:https|http):\/\/amazon.de\/dp\/([A-Z0-9]+)\/?$/;
    if (amazon.test(request.body.title)) {
        console.log("Found Amazon URL to request data.");
        Request.get(request.body.title)
            .then((data) => {
                console.log("Downloaded", data.length);
                response.status(200).json({ success: true });
            }).catch((error) => {
                console.error("Failure", error);
                response.status(404).json({ success: false, error });
            });
        return;
    } else {
        return handle(
            request
            , response
            , Db.createItem(request.params.user, request.body)
        );
    }
});

app.delete(api("list/:user"), (request, response) => {
    return handle(
        request
        , response
        , Db.deleteItem(request.params.user, request.body)
    );
});

app.listen(app.get("port"), () => {
    console.info(
        "The server is listening to the port"
        , app.get("port")
        , "NODE_ENV ="
        , process.env.NODE_EN
    );
});