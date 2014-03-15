# coding utf-8

require "pry"
require "rexml/document"

module Plloy
  class Instance
    def initialize(file)
      @signatures = {}
      @fields = {}
      @atoms = {}
      @orders = {}

      doc = REXML::Document.new(File.read(file))

      doc.elements.each("alloy/instance/sig") do |sig|
        create_sig(sig)
      end
      doc.elements.each("alloy/instance/field") do |field|
        create_field(field)
      end

      # resolv ordering
      signatures.each do |sig|
        ordered_ary = []
        if %r{/Ord\z} =~ sig.label
          order_atom = sig.field("First").tuples[0][1]
          ordered_ary << order_atom
          nexts = sig.field("Next").tuples
          while order_atom = nexts.find{|i| i[1] == order_atom}
            order_atom = order_atom[2]
            ordered_ary << order_atom
          end
          @orders[sig] = ordered_ary
        end
      end
    end

    def create_sig(element)
      sig = Sig.new(self, element)
      @signatures[sig.id] = sig
    end

    def signatures
      @signatures.values
    end

    def signature(id_or_label)
      if id_or_label.is_a?(Integer)
        @signatures[id_or_label]
      else
        label = id_or_label.to_s
        label = "this/" + label unless label.include?("/")
        @signatures.values.find{|s| s.label == label}
      end
    end

    def create_field(element)
      field = Field.new(self, element)
      @fields[field.id] = field
      sig = @signatures.values.find{|s| s == field.parent }
      sig.add_field(field)
      field
    end

    def fields
      @fields.values
    end

    def field(id)
      @fields[id]
    end

    def [](name, parent_name=nil)
      @fields.values.find{|field| field.label == name and (parent_name.nil? or parent_name == field.parent.label)}
    end

    def labels
      @fields.values.map{|field| field.label }
    end

    def create_atom(label)
      if @atoms[label]
        @atoms[label]
      else
        @atoms[label] = Atom.new(label)
        sig_name = label.sub(/\$\d+\z/, "")
        sig = signature(sig_name)
        sig.add_atom(@atoms[label])
        @atoms[label]
      end
    end

    def atoms
      @atoms.values
    end

    def orders
      @orders
    end

    def order(sig_name)
      @orders.find{|s, o| s.label == sig_name}[1]
    end
  end

  class Sig
    attr_reader :label, :id, :one, :priv

    def initialize(instance, element)
      @instance = instance
      @label = element.attributes["label"].dup.freeze
      @id = Integer(element.attributes["ID"])
      parent_id = element.attributes["parentID"]
      @parent_id = Integer(parent_id) if parent_id
      @one = !!element.attributes["one"]
      @priv = !!element.attributes["priv"]
      @atoms = []
      @fields = {}
    end

    def parent
      if @parent_id
        @parent ||= instance.signature(@parent_id)
      end
    end

    def add_field(field)
      @fields[field.label] = field
    end

    def add_atom(atom)
      @atoms << atom
    end

    def fields
      @fields.values
    end

    def field(name)
      @fields[name]
    end

    def atoms
      @atoms.dup
    end

    def to_s
      @label
    end

    def inspect
      @label.inspect
    end
  end

  class Field
    attr_reader :label, :id, :tuples, :types

    def initialize(instance, element)
      @instance = instance
      @label = element.attributes["label"].dup.freeze
      @id = Integer(element.attributes["ID"])
      @parent_id = Integer(element.attributes["parentID"])

      @types = []
      element.elements.each("types/type") do |i|
        @types << @instance.signature(Integer(i.attributes["ID"]))
      end

      @tuples = []
      element.elements.each("tuple") do |tuple|
        t = []
        tuple.elements.each("atom") do |atom|
          t << @instance.create_atom(atom.attributes["label"])
        end
        @tuples << t
      end
    end

    def parent
      @parent ||= @instance.signature(@parent_id)
    end

    def to_s
      @label
    end

    def inspect
      @label + "/" + @types.inspect
    end
  end

  class Atom
    attr_reader :label

    def initialize(label)
      @label = label
    end

    def to_s
      @label
    end

    def inspect
      @label.inspect
    end
  end

  def self.load(file)
    instance = Instance.new(file)
  end
end

if $0 == __FILE__
  include Plloy

  xml, = ARGV
  if xml
    @instance = Plloy.load(xml)
  end

  binding.pry
end
