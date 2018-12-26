import unittest
import helpers
from typetraits import nil

# type[T] is the type of a type T. The Nim manual explains:
#[
  In many contexts, Nim allows you to treat the names of types as regular values. 
  These values exists only during the compilation phase, but since all values 
  must have a type, type is considered their special type.

  type acts like a generic type. For instance, the type of the symbol int is 
  type[int]. Just like with regular generic types, when the generic param is ommited, 
  type denotes the type class of all types. 
]#
# The opening phrase above, "In many contexts", leaves a lot to our imagination.
# Let's see what we can figure out.

# We can pass a type literal as a proc parameter. The Nim manual explains:
#[
  Procs featuring type params are considered implicitly generic. They will be 
  instantiated for each unique combination of supplied types and within the body 
  of the proc, the name of each param will refer to the bound concrete type:  
]#
proc p1(t: type, v: t): t = v

test "pass type literal to proc":
  check(p1(int, 42) == 42)

# Consistent with the manual's statement that "these values exists only during
# the compilation phase", We can't store a type literal in a top-level variable.

doesnt_compile:
  var t = int

doesnt_compile:
  let t = int

# Interestingly though, we can store a type literal in a const:
test "pass type const to proc":
  const intTypeConst = int
  check(p1(intTypeConst, 42) == 42)

# The Nim manual explains ``const`` as follows:
#[
  Constants are symbols which are bound to a value. The constant's value cannot
  change. The compiler must be able to evaluate the expression in a constant
  declaration at compile time.
]#

# The manual's only clearly stated distinction between a ``const`` and a 
# ``let`` is that a ``let``s value is not required to be computable at compile
# time:
#[
  A let statement declares new local and global single assignment variables and
  binds a value to them. The syntax is the same as that of the var statement,
  except that the keyword var is replaced by the keyword let. Let variables are
  not l-values and can thus not be passed to var parameters nor can their
  address be taken. They cannot be assigned new values.
]#
# Perhaps once implementation of static[T] is finished, the following would
# work. (How would it be different from const?)
# let t: static[type[int]] = int

# There is also an issue #10004 suggesting, reasonably, that the following
# should work:
doesnt_compile:
  static:
    let t: type[int] = int

# Once we have put a type value in a ``const``, we have created the appearance
# that we could use it at runtime. But to prove that, we would need some
# operation on the ``const`` that knew was carried out at runtime. For
# example, the following does *not* demonstrate runtime use of our type-valued
# const because the checked conditions can be evaluated at compile time:
test "use type-valued const in a constant expression":
  const myIntType = int
  check(typetraits.name(myIntType) == "int")
  check(not (myIntType is string))

# The above use of ``typetraits.name`` is interesting, because it takes a
# ``typedesc`` parameter -- *not* a `type`. The 0.19.0 release notes
# (https://nim-lang.org/blog/2018/09/26/version-0190-released.html) 
# explain what is happening there:
#[
  the typedesc special type has been renamed to just type.
]#

# Let's see what else we can and cannot do with type values.

# The following behavior is truly weird!
test "``if`` returning a type value":
  let n = typetraits.name(if true: int else: string)
  check(n == "None")
