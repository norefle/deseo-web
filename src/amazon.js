const Cheerio = require("cheerio");
const Request = require("request-promise-native");

const URL_REGEX = /^(?:https|http):\/\/(?:www\.)?amazon\.(de|com)\/(?:[\w\/]*)\/([A-Z0-9]{10})(?:.*)$/;
const PRICE_REGEX = /^EUR\s*([0-9]+.?[0-9]*)$/;

function checkUrl(url) {
    return URL_REGEX.test(url);
}

function parse(url) {
    let matched = URL_REGEX.exec(url);
    if (matched && matched[1]) {
        let region = matched[1];
        let id = matched[2];
        let productPage = `https://amazon.${region}/dp/${id}`;
        return Request.get(productPage + "?language=en_GB").then((data) => {
            let $ = Cheerio.load(data);
            let title = $("#productTitle").text();
            let priceString = $("#priceblock_ourprice").text();
            let price = PRICE_REGEX.exec(priceString);
            price = price ? price[1] : null;
            let image = $("#landingImage");
            let imageUrl = image && image[0] && image[0].attribs
                ? image[0].attribs["data-old-hires"]
                : null;
            return {
                title: title ? title.trim() : null
                , price: price ? Math.ceil(price * 100) : null
                , image: imageUrl
                , url: productPage
            };
        });
    } else {
        return new Promise((resolve, reject) => {
            reject(`Invalid URL ${url}`);
        });
    }
}

module.exports = {
    checkUrl: checkUrl
    , parse: parse
}