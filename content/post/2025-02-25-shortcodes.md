---
title: Hugo Shortcodes for ECharts
author: 黄湘云
date: '2025-02-25'
slug: hugo-shortcodes-for-echarts
categories:
  - Hugo
tags:
  - shortcodes
  - echarts
---


下面通过 Hugo 的 shortcodes 引入 echarts 绘图功能

{{<echarts width="900px" height="600px">}}
var option = {
  title: {
    text: 'ECharts Getting Started Example'
  },
  tooltip: {},
  legend: {
    data: ['sales']
  },
  xAxis: {
    data: ['Shirts', 'Cardigans', 'Chiffons', 'Pants', 'Heels', 'Socks']
  },
  yAxis: {},
  series: [
    {
      name: 'sales',
      type: 'bar',
      data: [5, 20, 36, 10, 10, 20]
    }
  ]
};
{{</echarts>}}
