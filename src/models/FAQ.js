const pool = require("../../db");
const https = require("https");
const http = require("http");
const {PDFParse} = require("pdf-parse");

const downloadPDF = (url) => {
  return new Promise((resolve, reject) => {
    const client = url.startsWith("https://") ? https : http;

    client
      .get(url, (response) => {
        if (
          response.statusCode >= 300 &&
          response.statusCode < 400 &&
          response.headers.location
        ) {
          return downloadPDF(response.headers.location)
            .then(resolve)
            .catch(reject);
        }

        if (response.statusCode !== 200) {
          reject(
            new Error(
              `Failed to download PDF. Status: ${response.statusCode}`
            )
          );
          return;
        }

        const chunks = [];

        response.on("data", (chunk) => {
          chunks.push(chunk);
        });

        response.on("end", () => {
          resolve(Buffer.concat(chunks));
        });

        response.on("error", reject);
      })
      .on("error", reject);
  });
};

const parseFAQText = (text) => {
  const cleanedText = text
    .replace(/--\s*\d+\s*of\s*\d+\s*--/g, "")
    .replace(/\r/g, "")
    .trim();

  const questionRegex = /(?:^|\n)\s*(\d+)\.\s*(.+?)\s*\n/g;
  const matches = [...cleanedText.matchAll(questionRegex)];

  const faqs = [];

  for (let i = 0; i < matches.length; i++) {
    const match = matches[i];

    const question = match[2].trim();

    const answerStart = match.index + match[0].length;
    const answerEnd =
      i + 1 < matches.length
        ? matches[i + 1].index
        : cleanedText.length;

    const answer = cleanedText
      .slice(answerStart, answerEnd)
      .replace(/\s+/g, " ")
      .trim();

    if (question && answer) {
      faqs.push({
        question,
        answer,
      });
    }
  }

  return faqs;
};

const FAQ = {
  async getByRole(role) {
    const normalizedRole =
      String(role).trim().toUpperCase() === "CUSTOMER"
        ? "USER"
        : String(role).trim().toUpperCase();

    const result = await pool.query(
      `
      SELECT
        id,
        role,
        document_type,
        document_link,
        is_active,
        created_at,
        updated_at,
        created_by
      FROM faqs
      WHERE role = $1
        AND document_type = 'FAQS'
        AND is_active = true
      ORDER BY id ASC
      LIMIT 1
      `,
      [normalizedRole]
    );

    const faq = result.rows[0];

    if (!faq) {
      return null;
    }

    const pdfBuffer = await downloadPDF(faq.document_link);

const parser = new PDFParse({data: pdfBuffer});
const pdfData = await parser.getText();
await parser.destroy();

const documentText = pdfData.text.trim();
const faqItems = parseFAQText(documentText);

return {
  ...faq,
  faqs: faqItems,
};
 
  },
};

module.exports = FAQ;