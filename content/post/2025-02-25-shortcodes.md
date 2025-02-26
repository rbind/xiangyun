---
title: Hugo Shortcodes for ECharts
author: 黄湘云
date: '2025-02-25'
slug: hugo-shortcodes-for-echarts
categories:
  - 开源软件
tags:
  - shortcodes
  - echarts
  - Hugo
---

在写博客的过程中，有时候会需要绘制一些简单的统计图形，插入在正文中。图形所含数据不多，很轻量，所以，我不想用到 R 包 [echarts4r](https://github.com/JohnCoene/echarts4r)，既然不需要 R 的绘图和计算功能，那么，我也不需要用 R Markdown 文档来写我的博客文章了，直接用 Markdown 这种纯文本格式。我试了 [Chart.js](https://www.chartjs.org/docs/latest/) （适合极简单的图形）和 [Mermaid](https://github.com/mermaid-js/mermaid) （画非统计图形合适）。最后，在体验 [plotly](https://github.com/plotly/plotly.js)（虽然慢点，但是统计功能还是非常强的） 之后，发现我的这个使用场景还是 [Apache ECharts](https://echarts.apache.org/zh/index.html) 比较好。

我的网站是用 [Hugo](https://github.com/gohugoio/hugo) 来渲染的，它通过自定义的 [Shortcodes](https://gohugo.io/shortcodes/) 可以引入外部的 JavaScript 库。
Hugo 有一些内建的 Shortcodes，比如插入图片、油管视频等。

{{< figure
  src="/img/avocado.png"
  alt="I just feel so empty inside"
  link="https://x.com/OpenAI/status/1704545442749628695"
  caption="来源：OpenAI DALL·E 3 模型生成"
>}}

下面通过 Hugo 的 shortcodes 引入 echarts 绘图功能。ECharts 部分的代码复制自[ECharts 官网的快速上手文档](https://echarts.apache.org/handbook/zh/get-started/)。

{{<plotly>}}
var data = [
  {
    x: ['衬衫', '羊毛衫', '雪纺衫', '裤子', '高跟鞋', '袜子'],
    y: [5, 20, 36, 10, 10, 20],
    type: 'bar'
  }
];
var layout = {
  title: {
      text: '销量'
    }
  };
{{</plotly>}}

{{<echarts width="800px" height="400px">}}
// 指定图表的配置项和数据
var option = {
  title: {
    text: 'ECharts 入门示例'
  },
  tooltip: {},
  legend: {
    data: ['销量']
  },
  xAxis: {
    data: ['衬衫', '羊毛衫', '雪纺衫', '裤子', '高跟鞋', '袜子']
  },
  yAxis: {},
  series: [
    {
      name: '销量',
      type: 'bar',
      data: [5, 20, 36, 10, 10, 20]
    }
  ]
};
{{</echarts>}}

我是在写博客文章[《搞物流的互联网公司》](/2025/02/logistics/)的过程中，发现我需要引入 echarts 的绘图功能的。场景是这样的，翻一翻上市公司的财报，把其中某个指标的数据找出来，挨个复制到我的文档里来。根据需要画一些可对比的趋势图、饼图。原文中的两张饼图用ECharts 重画如下。

京东集团 2018 vs 2023 年全年净收入的分布如下。

{{<echarts>}}
option = {
  title: [{
    text: '京东集团 2018 vs 2023 年全年净收入',
    subtext: '数据来源于京东集团财报',
    left: 'center'
  },
  {
    subtext: '2018年',
    left: '25%',
    top: '47.5%',
    textAlign: 'center'
  },
  {
    subtext: '2023年',
    left: '75%',
    top: '47.5%',
    textAlign: 'center'
  }
  ],
  tooltip: {
    trigger: 'item',
    formatter: '{a} <br/>{b} : {c} ({d}%)'
  },
  legend: {
    orient: 'vertical',
    left: 'left'
  },
  series: [
    {
      name: '2018年',
      type: 'pie',
      radius: [80, 180],
      center: ['25%', '50%'],
      // roseType: 'radius',
      itemStyle: {
        borderRadius: 5
      },
      label: {
        show: false,
        position: 'center'
      },
      data: [
        { value: 280059, name: 'Electronics and home appliance' },
        { value: 136050, name: 'General merchandise' },
        { value: 33532, name: 'Marketplace and advertising' },
        { value: 12379, name: 'Logistics and other service' }
      ]
    },
    {
      name: '2023年',
      type: 'pie',
      radius: [80, 180],
      center: ['75%', '50%'],
      // roseType: 'radius',
      itemStyle: {
        borderRadius: 5
      },
      label: {
        show: false,
        position: 'center'
      },
      data: [
        { value: 538799, name: 'Electronics and home appliance' },
        { value: 332425, name: 'General merchandise' },
        { value: 84726, name: 'Marketplace and advertising' },
        { value: 128712, name: 'Logistics and other service' }
      ]
    }
  ]
};
{{</echarts>}}

先想好要从财报中找什么数据，找到数据后想着要怎么呈现，再从 ECharts 示例库中把相关图形的代码复制到我的文档里来，最后，挨个复制财报的数据，粘贴到 ECharts 绘图代码中的对应位置。

最后，查看本文源码文档[点这里](https://github.com/rbind/xiangyun/edit/main/content/post/2025-02-25-shortcodes.md)，感谢肖楠提供的[帮助](https://d.cosx.org/d/425576)。
