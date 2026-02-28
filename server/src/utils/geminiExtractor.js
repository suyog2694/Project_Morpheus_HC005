/**
 * Gemini API Extractor Utility
 * 
 * Integrates with Google's Gemini API to extract medical keywords
 * from patient condition descriptions.
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini client (lazy initialization)
let genAI = null;
let model = null;

/**
 * Initialize Gemini API client
 */
const initializeGemini = () => {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error('GEMINI_API_KEY environment variable is required');
  }

  if (!genAI) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  }

  return model;
};

/**
 * Medical keyword extraction prompt template
 */
const EXTRACTION_PROMPT = `You are a medical keyword extractor for an emergency ambulance system.

Given a patient condition description, extract ONLY the relevant medical keywords that would help a hospital prepare for the patient.

Return the response as a JSON object with the following structure:
{
  "keywords": ["keyword1", "keyword2", ...],
  "severity": "low" | "medium" | "high" | "critical",
  "specialties_needed": ["specialty1", "specialty2", ...],
  "equipment_needed": ["equipment1", "equipment2", ...]
}

Rules:
1. Extract only medically relevant terms
2. Include symptoms, conditions, injuries, and vital signs mentioned
3. Determine severity based on the description
4. Suggest medical specialties that may be needed
5. Suggest equipment that may be required
6. If the description is unclear, still provide your best assessment
7. Keep keywords concise and standardized

Patient condition description:
`;

/**
 * Extract medical keywords from patient condition text
 * 
 * @param {string} conditionText - Patient condition description from Flutter app
 * @returns {Promise<Object>} Extracted medical data
 */
const extractMedicalKeywords = async (conditionText) => {
  if (!conditionText || typeof conditionText !== 'string' || conditionText.trim().length === 0) {
    return {
      keywords: [],
      severity: 'medium',
      specialties_needed: ['general'],
      equipment_needed: [],
      raw_text: conditionText || ''
    };
  }

  try {
    const geminiModel = initializeGemini();
    
    const prompt = EXTRACTION_PROMPT + conditionText;
    
    const result = await geminiModel.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Parse the JSON response
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.warn('Gemini response did not contain valid JSON, using fallback');
      return createFallbackResponse(conditionText);
    }

    const extracted = JSON.parse(jsonMatch[0]);

    // Validate and sanitize response
    return {
      keywords: Array.isArray(extracted.keywords) ? extracted.keywords : [],
      severity: validateSeverity(extracted.severity),
      specialties_needed: Array.isArray(extracted.specialties_needed) 
        ? extracted.specialties_needed 
        : ['general'],
      equipment_needed: Array.isArray(extracted.equipment_needed) 
        ? extracted.equipment_needed 
        : [],
      raw_text: conditionText
    };

  } catch (error) {
    console.error('Gemini extraction error:', error.message);
    return createFallbackResponse(conditionText);
  }
};

/**
 * Validate severity level
 * 
 * @param {string} severity - Severity from Gemini
 * @returns {string} Validated severity
 */
const validateSeverity = (severity) => {
  const validSeverities = ['low', 'medium', 'high', 'critical'];
  return validSeverities.includes(severity) ? severity : 'medium';
};

/**
 * Create fallback response when Gemini fails
 * 
 * @param {string} conditionText - Original condition text
 * @returns {Object} Fallback medical data
 */
const createFallbackResponse = (conditionText) => {
  // Basic keyword extraction using common medical terms
  const commonMedicalTerms = [
    'pain', 'bleeding', 'breathing', 'chest', 'heart', 'head', 'accident',
    'unconscious', 'fracture', 'injury', 'burn', 'fever', 'seizure',
    'stroke', 'attack', 'pressure', 'diabetes', 'allergy', 'difficulty',
    'trauma', 'wound', 'broken', 'dizzy', 'nausea', 'vomiting'
  ];

  const lowerText = conditionText.toLowerCase();
  const foundKeywords = commonMedicalTerms.filter(term => lowerText.includes(term));

  // Basic severity detection
  const criticalTerms = ['unconscious', 'not breathing', 'heart attack', 'stroke', 'severe bleeding'];
  const highTerms = ['chest pain', 'difficulty breathing', 'accident', 'trauma'];
  
  let severity = 'medium';
  if (criticalTerms.some(term => lowerText.includes(term))) {
    severity = 'critical';
  } else if (highTerms.some(term => lowerText.includes(term))) {
    severity = 'high';
  }

  return {
    keywords: foundKeywords.length > 0 ? foundKeywords : ['emergency'],
    severity,
    specialties_needed: ['emergency'],
    equipment_needed: [],
    raw_text: conditionText,
    is_fallback: true
  };
};

module.exports = {
  extractMedicalKeywords,
  createFallbackResponse
};
