const { MongoClient, ObjectId } = require("mongodb");

const DB_URL = process.env.DB_URL;
const DB_USER = process.env.DB_USER;
const DB_PASSWD = process.env.DB_PASSWD;

const COLLECTION_NAME_USERS = "users";
const COLLECTION_NAME_LISTS = "lists";

function client() {
    let url = `mongodb://${DB_USER}:${DB_PASSWD}@${DB_URL}`;
    return MongoClient.connect(url);
}

function collection(name, callback) {
    return client().then((db) => {
        return callback(db.collection(name)).then((data) => {
            db.close();
            return data;
        }).catch((error) => {
            db.close();
            throw error;
        });
    });
}

function listLists(user) {
    return collection(COLLECTION_NAME_USERS, (table) => {
        // TODO: list all lists user could read, write, own
        return table.find({ owner: user }).toArray();
    }).then((lists) => {
        if (!lists || lists.length === 0) {
            return createList(user, "default");
        } else {
            return new Promise((resolve, reject) => {
                resolve(lists);
            });
        }
    }).then((data) => {
        return data;
    });
}

function createList(user, name) {
    return collection(COLLECTION_NAME_USERS, (table) => {
        return table.insertOne({
            list: name
            , owner: user
            , readers: []
            , writers: []
            , created: new Date().toISOString()
        });
    }).then((data) => {
        return data.ops;
    });
}

function getAccess(user, listId) {
    return listLists(user).then((lists) => {
        let list = lists.find((element) => {
            return element._id.toString() === listId;
        });

        return {
            owner: list ? list.owner === user : false
            , read: list ? list.readers.some((value) => { value === user }) : false
            , write: list ? list.writers.some((value) => { value === user }) : false
        };
    });
}

function listItems(user, listId) {
    return getAccess(user, listId).then((access) => {
        if (access.owner || access.read) {
            return collection(COLLECTION_NAME_LISTS, (table) => {
                return table.find({ user }).toArray();
            });
        } else {
            throw "Access denied";
        }
    }).then((data) => {
        return data;
    });
}

function createItem(user, listId, item) {
    return getAccess(user, listId).then((access) => {
        if (access.owner || access.write) {
            return collection(COLLECTION_NAME_LISTS, (table) => {
                item.user = user;
                return table.insertOne(item);
            });
        } else {
            throw "Access denied";
        }
    }).then((data) => {
        return data.ops;
    });
}

function deleteItem(user, listId, item) {
    return getAccess(user, listId).then((access) => {
        if (access.owner || access.write) {
            return collection(COLLECTION_NAME_LISTS, (table) => {
                return table.deleteOne({ _id: ObjectId(item.id) });
            });
        } else {
            throw "Access denied";
        }
    }).then((data) => {
        return true;
    });
}

module.exports = {
    listLists: listLists
    , createList: createList
    , listItems: listItems
    , createItem: createItem
    , deleteItem: deleteItem
};
