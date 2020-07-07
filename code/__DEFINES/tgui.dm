/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI Should close
#define UI_CLOSE -1
/// UI is actively in the process of closing
#define UI_CLOSING -2

/// Maximum number of windows that can be suspended/reused
#define TGUI_WINDOW_SOFT_LIMIT 3
/// Maximum number of open windows
#define TGUI_WINDOW_HARD_LIMIT 6

/// Window does not exist
#define TGUI_WINDOW_CLOSED 0
/// Window was just opened, but is still not ready to be sent data
#define TGUI_WINDOW_LOADING 1
/// Window is free and ready to receive data
#define TGUI_WINDOW_FREE 2
/// Window is in use by a tgui datum
#define TGUI_WINDOW_ALLOCATED 3
/// Window is broken and must be closed
#define TGUI_WINDOW_BROKEN 4

/// Get a window id based on the provided pool index
#define TGUI_WINDOW_ID(index) "tgui-window-[index]"
/// Get a pool index of the provided window id
#define TGUI_WINDOW_INDEX(window_id) text2num(copytext(window_id, 13))
