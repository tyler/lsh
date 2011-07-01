require 'rubygems'
require 'bitset'
require 'enumerable'
require 'pqueue'

class LSH
  class Collection
    def initialize(bitwidth, vector_length)
      @bitwidth = bitwidth
      @random_vectors = @bitwidth.times.map { random_vector(vector_length) }

      @ids = []
      @bitsets = []
    end

    attr_reader :bitsets

    def add(id, vector)
      @ids << id
      @bitsets << lsh(vector)
    end

    def nearest_neighbors(id, k)
      bitset = @bitsets[@ids.index(id)]
      q = PQueue.new(k)
      @bitsets.each_with_index do |other_bitset,i|
        q.add(@ids[i], bitset.hamming(other_bitset))
      end
      q
    end

    private

    def lsh(vector)
      bitset = Bitset.new(@bitwidth)

      @random_vectors.each_with_index do |random_vector, i|
        sum = 0
        vector.each { |k,v| sum += random_vector[k] ? v : -v }
        bitset[i] = sum > 0
      end

      bitset
    end

    def random_vector(length)
      vector = Bitset.new(length)
      length.times { |i| vector[i] = rand(2) == 0 }
      vector
    end
  end
end

if __FILE__ == $0
  def random_vector(min,max,length,freq)
    v = {}
    length.times do |i| 
      next unless rand < freq
      v[i] = rand(max-min) + min
    end
    v
  end

  def cosine_sim(a,b)
    a.inject(0) { |sum,(k,v)| sum + (b[k] ? b[k] * v : 0) }.to_f / (a.values.magnitude.to_f * b.values.magnitude.to_f)
  end

  def munge_vector(v,length,min,max)
    out = v.dup
    v.keys.each do |k|
      out.delete(k) if rand > 0.95
      out[k] = rand(max-min) + min if rand < 0.1
      out[rand(length)] = rand(max-min) + min if rand < 0.1
    end
    out
  end

  puts "Initializing LSH::Collection..."
  lsh = LSH::Collection.new(128, 500_000)

  puts "Initializing random document vectors..."
  documents = []
  documents << random_vector(1.0, 100.0, 500_000, 0.01)
  24.times {
    documents << munge_vector(documents.last, 500_000, 1.0, 100.0)
  }

  puts "Adding documents to the collection..."
  documents.each_with_index do |document,id|
    puts "  Adding document ##{id}"
    lsh.add(id,document)
  end

  puts "Getting nearest neighbors..."
  documents.each_with_index do |document,id|
    puts "  Nearest neighbors for document ##{id}:"

    actual = documents.map.with_index { |other,i| [i, cosine_sim(document, other)] }.sort_by { |a,b| -b }[0,5]
    puts "    Actual: #{actual.inspect}"

    pq = lsh.nearest_neighbors(id, 5)
    puts "    LSH: #{pq.items.inspect}"
  end
end
