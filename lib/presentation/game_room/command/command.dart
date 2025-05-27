// Command interface
abstract class Command {
  void execute();
  void undo();
  void redo();
}