const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

exports.analyzeIngredients = functions.https.onCall(async (data, context) => {
  // 1. Ensure the user is authenticated.
  if (!data.user) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  // 2. Safely access the API key and initialize the Gemini client INSIDE the handler.
  const API_KEY = functions.config().gemini?.key;
  if (!API_KEY) {
    // This provides a clear error if the key was never set.
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The Gemini API key is not configured. Please ask the developer to set it."
    );
  }
  const genAI = new GoogleGenerativeAI(API_KEY);

  // 3. Get the base64 image string from the app.
  const base64Image = data.image;
  if (!base64Image) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with an 'image' argument."
    );
  }

  try {
    // 4. Prepare the model (use gemini-pro-vision for image input).
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-preview-05-20" });

    const imagePart = {
      inlineData: {
        mimeType: "image/jpeg",
        data: base64Image,
      },
    };

    const prompt = `
      You are an AI food safety assistant named 'Fit2Eat'. Your task is to analyze the provided image of a packaged food's ingredients list.

      Based on the ingredients, you must determine:
      1. If the food is generally fit for consumption for a healthy adult ('isFitToEat'). Bias towards 'true' unless there are highly processed or controversial ingredients.
      2. A list of potentially harmful ingredients and their common negative effects ('harmfulIngredients').
      3. A list of warnings for people with specific health conditions (e.g., celiac disease, lactose intolerance, high blood pressure) who should avoid this item ('warnings').

      You MUST return your response as a single, minified JSON object with no extra text or markdown formatting. The JSON object must strictly follow this structure:
      {
        "isFitToEat": boolean,
        "harmfulIngredients": [
          {
            "name": "Ingredient Name",
            "effects": "Description of harmful effects."
          }
        ],
        "warnings": [
          "Condition: Rationale for avoidance."
        ]
      }
    `;

    // 5. Call the Gemini API with the prompt and the image.
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    // 6. Parse the JSON text and return it to the Flutter app.
    return JSON.parse(text);

  } catch (error) {
    console.error("Error calling Gemini API or parsing response:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to analyze ingredients.",
      error
    );
  }
});