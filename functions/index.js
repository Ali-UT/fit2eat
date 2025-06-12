const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

exports.analyzeIngredients = functions.https.onCall(async (data, context) => {
  console.log("Function triggered.");

  // 1. Authenticated check
  // if (!context.auth) {
  //   console.error("Authentication check failed. No user.");
  //   throw new functions.https.HttpsError(
  //     "unauthenticated", "The function must be called while authenticated."
  //   );
  // }
  // console.log(`Authenticated as user: ${context.auth.uid}`);
  const clientData = data.data;
  // Safely log the keys of the incoming data object to see what we received.
  if (clientData) {
    console.log("Data object received with keys:", Object.keys(clientData));
  } else {
    console.error("Data object is null or undefined.");
    throw new functions.https.HttpsError("invalid-argument", "Data object is missing.");
  }

  // 2. Use process.env for V2 functions to get the secret key
  const API_KEY = process.env.GEMINI_KEY;
  if (!API_KEY) {
    console.error("GEMINI_KEY environment variable is not set.");
    throw new functions.https.HttpsError(
      "failed-precondition", "The Gemini API key is not configured."
    );
  }
  const genAI = new GoogleGenerativeAI(API_KEY);
  console.log("Gemini client initialized.");

  // 3. Image data check
  const base64Image = clientData.image;
  if (!base64Image) {
    console.error("Image data is missing from the request.");
    throw new functions.https.HttpsError(
      "invalid-argument", "The function must be called with an 'image' argument."
    );
  }
  console.log("Image data received.");

  try {
    // 4. Prepare the model you requested
    const modelName = "gemini-2.5-flash-preview-05-20";
    console.log(`Initializing model: ${modelName}`);
    const model = genAI.getGenerativeModel({ model: modelName });

    const imagePart = {
      inlineData: { mimeType: "image/jpeg", data: base64Image },
    };

    const prompt = `
      You are an AI food safety assistant named 'Fit2Eat'. Your task is to analyze the provided image of a packaged food's ingredients list.
      Based on the ingredients, you must determine:
      1. If the food is a decently healthy choice for consumption ('isFitToEat').
      2. A list of potentially harmful ingredients and their effects ('harmfulIngredients').
      3. A list of warnings for people with specific health conditions ('warnings').
      You MUST return your response as a single, minified JSON object with no extra text or markdown formatting. The JSON object must strictly follow this structure:
      {
        "isFitToEat": boolean,
        "harmfulIngredients": [{"name": "Ingredient Name", "reason": "Description"}],
        "warnings": ["Condition: Rationale for avoidance."]
      }
    `;

    // 5. Call the Gemini API
    console.log("Sending request to Gemini API...");
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();
    console.log("Received response from Gemini.");
    console.log("Gemini Raw Text:", text);

    // 6. Parse the response
    console.log("Parsing JSON response...");
    const parsedResponse = JSON.parse(text);
    console.log("JSON parsed successfully. Returning to client.");
    return parsedResponse;

  } catch (error) {
    console.error("!!! CRITICAL ERROR inside function execution:", error);
    throw new functions.https.HttpsError("internal", "Failed to analyze ingredients.", error.message);
  }
});