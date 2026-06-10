from pathlib import Path
import json
import sys
import time
from paddleocr import PaddleOCR

image_path = sys.argv[1]
result_dir = Path(sys.argv[2])
result_dir.mkdir(parents=True, exist_ok=True)

ocr = PaddleOCR(
    text_detection_model_name="PP-OCRv5_mobile_det",
    text_recognition_model_name="korean_PP-OCRv5_mobile_rec",
    enable_mkldnn=False,
    use_doc_orientation_classify=False,
    use_doc_unwarping=False,
    use_textline_orientation=False,
)

total_start = time.perf_counter()
infer_start = time.perf_counter()
prediction = ocr.predict(image_path)
result = prediction[0] if isinstance(prediction, list) else next(prediction)
infer_seconds = time.perf_counter() - infer_start

result.save_to_json(str(result_dir))
result.save_to_img(str(result_dir))

payload = result.json
if isinstance(payload, str):
    payload = json.loads(payload)

texts = payload.get("res", {}).get("rec_texts", [])
text_path = result_dir / "recognized.txt"
text_path.write_text("\n".join(texts) + ("\n" if texts else ""), encoding="utf-8")
total_seconds = time.perf_counter() - total_start

print(f"json: {result_dir}")
print(f"text: {text_path}")
print(f"inference_seconds: {infer_seconds:.3f}")
print(f"total_seconds: {total_seconds:.3f}")
print("--- recognized text ---")
if texts:
    print("\n".join(texts))
else:
    print("(no text detected)")
