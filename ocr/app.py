import os
import base64
import io

from flask import Flask, request, jsonify
import pytesseract
from PIL import Image

app = Flask(__name__)

@app.route("/ocr", methods=["POST"])
def ocr():
    # Check if the request has the file part
    if "file" in request.files:
        # If we received a file directly (multipart/form-data)
        file = request.files["file"]
        image = Image.open(file.stream).convert("RGB")
        text = pytesseract.image_to_string(image)
        return jsonify({"text": text.strip()})
    else:
        # Otherwise, try parsing base64 from JSON
        data = request.get_json()
        if not data or "image" not in data:
            return jsonify({"error": "No image data found"}), 400

        # Decode base64 string
        try:
            image_data = base64.b64decode(data["image"])
            image = Image.open(io.BytesIO(image_data)).convert("RGB")
            text = pytesseract.image_to_string(image)
            return jsonify({"text": text.strip()})
        except Exception as e:
            return jsonify({"error": str(e)}), 400


@app.route("/", methods=["GET"])
def index():
    return "Tesseract OCR service is running."


if __name__ == "__main__":
    # You can make Flask listen on 0.0.0.0 so it is accessible from outside the container
    app.run(host="0.0.0.0", port=5000)