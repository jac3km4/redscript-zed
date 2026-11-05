module Example.Demo
//     ^ module
import Std.*
/// Documentation
@addMethod(Player)
// ^ attribute
public final class Demo<+T extends IScriptable> {
//                 ^ type
  private let value: [T];
//            ^ property
  default value = [];
  public func Run(opt name: String) -> String {
//            ^ function
//                    ^ variable.parameter
    /* outer /* nested */ comment */
    const count = 1ul;
//                ^ number
    let item = new Demo<T>();
    item.Run(, n"name",);
//       ^ function.method.call
    let label = s"Hello \(name), \(count + 1)";
//                ^ string
//                       ^ punctuation.special
    if let found? as T = item { return label; }
    return "fallback\n\u{41}";
//          ^ string
//                  ^ string.escape
  }
}
