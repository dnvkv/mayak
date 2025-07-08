In some situations Sorbet can not infer a type of proc passed:

```ruby
sig {
  type_parameters(:A)
    .params(blk: T.proc.params(arg0: T.type_parameter(:A)).returns(T.type_parameter(:A)))
    .returns(T.proc.params(arg0: T.type_parameter(:A)).returns(T.type_parameter(:A)))
}
def proc_identity(&blk)
  blk
end

T.reveal_type(proc_identity { |a| 10 })
# This code is unreachable https://srb.help/7006
# proc_identity { |a| 10 }
```

`Mayak::Fuction` allows explicitly define input and output types to help sorbet infer types:

```ruby
sig {
  type_parameters(:A)
    .params(
      fn: Mayak::Function[T.type_parameter(:A), T.type_parameter(:A)])
    .returns(Mayak::Function[T.type_parameter(:A), T.type_parameter(:A)])
}
def fn_identity(fn)
  fn
end

T.reveal_type(
  fn_identity(Mayak::Function[Integer, Integer].new { |a| a })
)
# Revealed type: Mayak::Function[Integer, Integer]
```