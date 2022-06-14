(function(d) {
  const q = x => d.querySelector('.article-' + x);
  const d1 = q('content'), d2 = q('duration'), d3 = q('wordcount');
  if (!d1 || !d2 || !d3) return;
  const t = d1.innerText, m1 = t.match(/\p{Script=Han}/ug), m2 = t.match(/[a-zA-Z0-9.]+/g);
  const n1 = m1 ? m1.length : 0, n2 = m2 ? m2.length : 0;
  d3.innerText += ' 约 ' + n1 + ' 汉字及 '+ n2 + ' 单词';
  d2.innerText += ' ' + Math.round((n1 + n2)/500) + ' 分钟';
})(document);
