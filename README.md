多椀バンディットのサンプルコード
===
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

[これからの強化学習](https://www.amazon.co.jp/dp/4627880316)の1.1節に出てくる多椀バンディット問題のRubyによるサンプル実装です。

Qiitaに解説を書きました。

[多椀バンディット問題のRuby実装@Qiita](https://qiita.com/kaityo256/items/b2c2d009d1e272fafd36)

# 使い方

    $ make

# 結果

![result.png](result.png)


* Random: ランダムに腕を選ぶ
* Greedy: 最初にn回ずつ試して、その中でもっとも報酬が良かったものを選ぶ
* ε-Greedy: これまでに最も報酬が良かった腕を選ぶが、確率εでランダム
* UCB1: Upper Confident Bound法で選ぶ

# ライセンス

MIT
