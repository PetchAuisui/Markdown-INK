# Markdown Ink Annotation

Flutter demo สำหรับเปิดและแสดง Markdown แล้วเขียนหมึกแบบ free-form ทับบนเอกสาร หมึกถูกเก็บแยกจาก Markdown และใช้พิกัดของเอกสาร จึงคงตำแหน่งเดิมเมื่อ scroll

## Features

- เปิดไฟล์ `.md`, `.markdown` หรือ `.txt` บน macOS และ Web
- render Markdown พร้อม scroll เอกสารยาว
- วาดด้วย stylus โดยแยกจาก finger scroll
- เปิด **Touch draws** เพื่อทดลองด้วยนิ้วหรือเมาส์
- Pen / eraser, สี, ความหนา, undo / redo และ clear
- บันทึกเอกสารล่าสุดและ ink อัตโนมัติใน local app storage
- โหลด ink เดิมกลับมาตามชื่อไฟล์เอกสาร

## Run

```bash
flutter pub get
flutter run -d macos
```

หรือรันบน Web:

```bash
flutter run -d chrome
```

ตรวจคุณภาพด้วย:

```bash
flutter analyze
flutter test
flutter build web --release
flutter build macos --release
```

## Structure

```text
lib/
├── main.dart
└── src/
    ├── annotation_page.dart
    ├── sample_markdown.dart
    ├── ink/
    │   ├── ink_canvas.dart
    │   ├── ink_controller.dart
    │   ├── ink_stroke.dart
    │   └── ink_toolbar.dart
    └── persistence/
        └── annotation_store.dart
```

`InkStroke` ถูก serialize เป็น JSON แล้วเก็บด้วย key แยกจาก Markdown เช่น `ink.lecture-notes.md.json` ภายใน `shared_preferences` สำหรับ demo นี้ ต้นฉบับ Markdown จึงไม่ถูกแก้ไข

## Input behavior

- Stylus / Apple Pencil: วาดหมึก
- Inverted stylus: ลบ stroke
- Finger, mouse wheel หรือ trackpad: scroll เมื่อ **Touch draws** ปิด
- Finger หรือ mouse drag: วาดเมื่อ **Touch draws** เปิด (scroll ถูกพักเพื่อไม่แย่ง gesture)

## Demo limitations

- ใช้ชื่อไฟล์เป็น document key; โปรเจกต์จริงควรใช้ path หรือ content hash ป้องกันชื่อซ้ำ
- eraser ลบทั้ง stroke ที่แตะ ไม่ได้ตัดเฉพาะช่วงของเส้น
- local storage เหมาะกับ demo; งาน production ควรใช้ไฟล์ sidecar `.ink.json` หรือฐานข้อมูล และเพิ่ม file export/import
- ความสูง canvas ขั้นต่ำตั้งไว้สำหรับเอกสารตัวอย่าง; งาน production ควรวัด layout และแบ่งเอกสารยาวเป็นหน้า/tiles
