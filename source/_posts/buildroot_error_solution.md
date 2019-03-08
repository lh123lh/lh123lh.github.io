---
title: Buildroot 编译失败解决方案
tags: 
	-嵌入式开发
date: 2019-03-06 18:30:00
---
在嵌入式linux开发过程中交叉编译buildroot时会出现很多错误导致编译无法继续进行,在此总结("抄袭",:stuck_out_tongue_winking_eye:)了一些错误解决方案以备后用.

<!-- more -->

## Error 1 : 
``` bash
gdate.c:2497:7: error: format not a string literal
```

### Reason : 
``` bash
编译类openwrt sdk时，出现个gdate.c的错误，与编译器版本有关，打个patch就好
```

### Solution:
``` bash
* Returns: number of characters written to the buffer, or 0 the buffer was too small
*/
+#pragma GCC diagnostic push
+#pragma GCC diagnostic ignored "-Wformat-nonliteral" 
+
gsize
g_date_strftime (gchar *s,
gsize slen,
@@ -2549,3 +2552,5 @@ g_date_strftime (gchar *s,
return retval;
#endif
}
+
+#pragma GCC diagnostic pop
```
<br/></br>
## Error 2 :  
``` bash
Unescaped left brace in regex is illegal here in regex; marked by <-- HERE in m/${ <-- HERE ([^ \t=:+{}]+)}/ at xxxx/usr/bin/automake line 3939.
```

### Reason : 
``` bash
出现的automake正则表达式问题。原因是Perl不支持以前的写法
```

### Solution:
``` bash
# $text =~ s/\${([^ \t=:+{}]+)}/substitute_ac_subst_variables_worker ($1)/ge;
$text =~ s/\$[{]([^ \t=:+{}]+)}/substitute_ac_subst_variables_worker ($1)/ge;
```
