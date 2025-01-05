import 'package:flutter/material.dart';
import 'package:ftoast/ftoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';


// empty textfield warning
dynamic emptyWarning(BuildContext context) {
  return FToast.toast(
    context,
    msg: "Oops!",
    subMsg: "You Must fill all fields",
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}

// nothing to update
dynamic updateTaskWarning(BuildContext context) {
  return FToast.toast(
    context,
    msg: "Oops!",
    subMsg: "You Must edit the tasks before updating!",
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}


// no task to delete
dynamic noTaskWarning(BuildContext context) {
  return PanaraInfoDialog.showAnimatedGrow(
    context,
    title: "Oops!",
    message: "There is no task to delete!\n try adding some and the try to delete it!",

    buttonText: "Okay",
    onTapDismiss: () {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.warning
  );
}


dynamic deleteAllTasks(BuildContext context, VoidCallback onDelete) {
  return PanaraConfirmDialog.showAnimatedGrow(
    context,
    title: "Are You Sure?",
    message: "Are you sure you want to delete all tasks?",
    confirmButtonText: "Yes",
    cancelButtonText: "No",
    onTapConfirm: () {
      onDelete(); 
      Navigator.pop(context);
    },
    onTapCancel: () {
      Navigator.pop(context); // Close the dialog without doing anything
    },
    panaraDialogType: PanaraDialogType.error,
  );
}
