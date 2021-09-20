class BlockCommand {
  String onTapCommand;
  String onTapValue;
  String onHoldCommand;
  String onHoldValue;
  
  BlockCommand(this.onTapCommand, this.onTapValue, this.onHoldCommand, this.onHoldValue);

  static List<String> blockActions = [
    "Load task",
    "Load page"
  ];

  Map<String, String> toJSON() {
    return {
      "tap_command": this.onTapCommand,
      "tap_command_value": this.onTapValue,
      "hold_command": this.onHoldCommand,
      "hold_command_value": this.onHoldValue
    };
  }
}