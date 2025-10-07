---
title: 回归故里
author: 黄湘云
date: '2025-10-07'
slug: reconnect
categories:
  - 推荐文章
tags:
  - 似水流年
---


{{<toc>}}


# 变了

部分新建住房、白事活动现场、村服务中心。

{{< gallery >}}
  <img src="/img/2025/IMG_0264.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0267.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0337.jpeg" class="grid-w33" />
  
  <img src="/img/2025/IMG_0269.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0270.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0271.jpeg" class="grid-w33" />
{{< /gallery >}}



# 没变

村前水坝、村二进堂屋、部分旧住房。

{{< gallery >}}
  <img src="/img/2025/IMG_0229.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0236.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0237.jpeg" class="grid-w33" />
  
  <img src="/img/2025/IMG_0238.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0239.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0240.jpeg" class="grid-w33" />
{{< /gallery >}}

卫生院门口、小学校门口、小庙。

{{< gallery >}}
  <img src="/img/2025/IMG_0224.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0233.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0258.jpeg" class="grid-w33" />
{{< /gallery >}}


# 做菜

再来点轻松的，只会做简单的饭菜，只够做自己的口味。

{{< gallery >}}
  <img src="/img/2025/IMG_0728.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0755.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0760.jpeg" class="grid-w33" />
{{< /gallery >}}


# 读书

沉下来读书是另一件让人轻松愉悦的事。

{{< gallery >}}
  <img src="/img/2025/IMG_0672.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0678.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0679.jpeg" class="grid-w33" />
{{< /gallery >}}


# 赏花

山中不知名白花开，竹林里紫藤花开，马路边牵牛花开。

{{< gallery >}}
  <img src="/img/2025/IMG_0602.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0613.jpeg" class="grid-w33" />
  <img src="/img/2025/IMG_0757.jpeg" class="grid-w33" />
{{< /gallery >}}


```r
# image resize
files <- list.files(path = "path/to/img/", full.names = T)
for (file_path in files) {
  magick::image_read(path = file_path) |> 
    magick::image_resize("800x800") |> 
    magick::image_write(path = file_path)
}
```
