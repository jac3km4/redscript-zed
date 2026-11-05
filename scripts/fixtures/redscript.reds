module Validation.Demo
/// Documentation for Demo
public class Demo<T> {
  private let value: T;
  public func Run(name: String) -> String {
    /* outer /* nested */ comment */
    let label = s"Hello \(name)";
    Ping(name);
    return label;
  }
}
func Top() {}
