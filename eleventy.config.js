export default async function (eleventyConfig) {
    eleventyConfig.addPassthroughCopy("src/assets");

    return {
        dir: {
            input: "src",
            output: "public"
        }
    };
}
