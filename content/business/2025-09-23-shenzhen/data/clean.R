library(pdftools)
# 抽取目标 PDF 页面并转化为 PNG
pdftools::pdf_convert(
  pdf = "~/Downloads/统计年鉴/深圳市/2024.pdf", pages = c(71, 75), 
  format = "png", # supported_image_formats
  dpi = 200, # 值越大图片越清晰
  filenames = c("data/1.png", "data/2.png")
)

library(magick)
# 识别 PNG 图片中的数字
input <- image_read("data/1.png")
# 去掉背景
text <- input %>%
  image_resize("2000x") %>%
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_write(format = 'png', density = '300x300')

# OCR 识别
text_ocr <- text %>%
  tesseract::ocr()
# 输出文本（主要是数字）复制到表格
cat(text_ocr, sep = "\\n")
