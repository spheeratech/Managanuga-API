const swaggerAutogen = require("swagger-autogen")();
const fs = require("fs");

const outputFile = "./swagger-output.json";
const endpointsFiles = ["./src/app.js"];

const document = {
  swagger: "2.0",
  info: {
    title: "Managanuga API",
    version: "1.0.0",
    description: "API documentation for the Managanuga backend",
  },
  securityDefinitions: {
    bearerAuth: {
      type: "apiKey",
      name: "Authorization",
      in: "header",
      description: "Enter: Bearer {JWT token}",
    },
  },
};

swaggerAutogen(outputFile, endpointsFiles, document).then(() => {
  const generatedDocument = JSON.parse(fs.readFileSync(outputFile, "utf8"));
  delete generatedDocument.host;
  delete generatedDocument.basePath;
  delete generatedDocument.schemes;
  fs.writeFileSync(outputFile, `${JSON.stringify(generatedDocument, null, 2)}\n`);
  console.log(`Swagger documentation generated at ${outputFile}`);
});