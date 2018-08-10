# 配列クラスに平均メソッドを追加
class Array
  def sum
    reduce(:+)
  end

  def mean
    sum.to_f / size
  end
end

# 複数のバンディットをまとめるクラス
class Casino
  Bandit = Struct.new(:prob, :award)

  def initialize(arr)
    @bandits = []
    arr.each do |prob, award|
      @bandits << Bandit.new(prob, award)
    end
  end

  # プレイする腕を選ぶと、その腕の確率でawardを返す
  def play(index)
    if @bandits[index].prob > rand
      @bandits[index].award
    else
      0
    end
  end
end

# プレイヤークラス
class Player
  def initialize(num:)
    @num_bandits = num
    @awards = 0.0
    @t = 0
  end

  def average_awards
    @awards.to_f / @t
  end
end

# ランダム
class RandomPlayer < Player
  def play(casino)
    @t += 1
    i = rand(@num_bandits)
    @awards += casino.play(i)
  end
end

# Greedy Player
class GreedyPlayer < Player
  # min: 最低何回試すか
  def initialize(num:, min:)
    super(num: num)
    @num_trials = Array.new(num) { 0 }
    @got_awards = Array.new(num) { 0 }
    @min_trials = min
  end

  def play(casino)
    @t += 1
    # まだ規定回数試していない腕があるか調べる
    i = @num_trials.find_index { |v| v < @min_trials }

    if i.nil? # すべて規定回数試した
      i = @got_awards.index(@got_awards.max)
      @awards += casino.play(i)
    else # 規定回数試していない腕がある
      a = casino.play(i)
      @got_awards[i] += a
      @awards += a
      @num_trials[i] += 1
    end
  end
end

# epsilon-Greedy
class EGreedyPlayer < Player
  # n: banditの数
  # e: 確率epsilon
  def initialize(num:, eps:)
    super({num: num})
    @num_trials = Array.new(num) { 0 }
    @got_awards = Array.new(num) { 0 }
    @epsilon = eps
  end

  def select_epsilon
    if rand < @epsilon # 確率epsilonでランダム
      rand(@num_bandits)
    else
      r = Array.new(@num_bandits) { |j| @got_awards[j].to_f / @num_trials[j] }
      r.index(r.max)
    end
  end

  def play(casino)
    @t += 1
    # まで試してない腕があったらそれを選ぶ
    i = @num_trials.find_index(&:zero?)
    i = select_epsilon if i.nil?
    a = casino.play(i)
    @num_trials[i] += 1
    @got_awards[i] += a
    @awards += a
  end
end

# UCB1戦略
class UCB1Player < Player
  # n: banditの数
  # e: 確率epsilon
  def initialize(num:)
    super({num: num})
    @num_trials = Array.new(num) { 0.0 }
    @got_awards = Array.new(num) { 0.0 }
    @max = 0.0
  end

  def select_ucb
    mu = @got_awards.zip(@num_trials).map { |x, y| x / y }
    r = Array.new(@num_bandits) do |j|
      # 半値幅
      u = Math.sqrt(2.0 * Math.log(@t) / @num_trials[j])
      # 期待値と半値幅の和を返す
      mu[j] + u
    end
    r.index(r.max)
  end

  def play(casino)
    @t += 1
    # まで試してない腕があったらそれを選ぶ
    i = @num_trials.find_index(&:zero?)

    # 全て試していたら半値幅と平均の和が最大の腕を選ぶ
    i = select_ucb if i.nil?
    a = casino.play(i)
    @num_trials[i] += 1
    @got_awards[i] += a
    @awards += a
    @max = a if @max < a
  end
end

N = 100
T = 10000

def test(pclass, args, casino)
  ninv = 1.0 / N
  r = Array.new(T) { 0.0 }
  N.times do
    player = pclass.new(args)
    T.times do |i|
      player.play(casino)
      r[i] += player.average_awards * ninv
    end
  end
  r
end

bs = [[0.2, 1], [0.3, 1], [0.4, 1], [0.5, 1]]
c = Casino.new(bs)

rp = test(RandomPlayer, {num: bs.size}, c)
gp = test(GreedyPlayer, {num: bs.size, min: 10}, c)
egp = test(EGreedyPlayer, {num: bs.size, eps: 0.1}, c)
up = test(UCB1Player, {num: bs.size}, c)

T.times do |t|
  puts "#{t} #{rp[t]} #{gp[t]} #{egp[t]} #{up[t]}" if (t % 100).zero?
end
