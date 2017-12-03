const Express = require("express");
const BodyParser = require("body-parser");
const Timeout = require("connect-timeout");

if (process.env.NODE_ENV !== "production") {
    console.log("Loading dev environment...");
    require("dotenv").config();
}

const Db = require(__dirname + "/db");
const Amazon = require(__dirname + "/amazon");

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

app.get(api("lists"), (request, response) => {
    return handle(
        request
        , response
        , Db.listLists(request.query.user)
    );
});

app.get(api("lists/:listId"), (request, response) => {
    return handle(
        request
        , response
        , Db.listItems(request.query.user, request.params.listId)
    );
});

app.post(api("lists/:listId"), (request, response) => {
    if (Amazon.checkUrl(request.body.title)) {
        let action = Amazon.parse(request.body.title).then((data) => {
            let updated = request.body;
            updated.id = null;
            updated.url = data.url || updated.title;
            updated.title = data.title || "";
            updated.image = data.image || "";
            updated.price = data.price || 0;
            updated.date = new Date().toISOString();
            console.log(updated);
            return updated;
        }).then((item) => {
            return Db.createItem(request.query.user, request.params.listId, item);
        });

        return handle(
            request
            , response
            , action
        );
    } else {
        return handle(
            request
            , response
            , Db.createItem(request.query.user, request.params.listId, request.body)
        );
    }
});

app.delete(api("lists/:listId"), (request, response) => {
    return handle(
        request
        , response
        , Db.deleteItem(request.query.user, request.params.listId, request.body)
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