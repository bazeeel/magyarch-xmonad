-- xmonad.hs
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import Data.Monoid
import System.Exit
--import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Spacing
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog)
import System.IO (Handle, hPutStrLn)
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders (noBorders, smartBorders) 
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Minimize
import XMonad.Hooks.EwmhDesktops

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Control.Monad (liftM2)
--import XMonad.ManageHook
--import XMonad.Util.NamedScratchpad



-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask


{--scratchpads = [
-- run htop in xterm, find it by title, use default floating window placement
    NS "htop" "alacritty -e htop" (title =? "htop") defaultFloating ,

-- run stardict, find it by class name, place it in the floating window
-- 1/6 of screen width from the left, 1/6 of screen height
-- from the top, 2/3 of screen width by 2/3 of screen height
    NS "stardict" "stardict" (className =? "Stardict")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

-- run gvim, find by role, don't float
    NS "notes" "gvim --role notes ~/notes.txt" (role =? "notes") nonFloating
 
 ] where role = stringProperty "WM_WINDOW_ROLE" --}

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--

--WORKSPACES

xmobarEscape = concatMap doubleLts
    where doubleLts '<' = "<<"
          doubleLts x = [x]

--myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces    = clickable . (map xmobarEscape) $ ["\61612","\61899","\61947","\61635","\61502","\61501","\61705","\61564","\62150","\61872"]
     where
               clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" | (i,ws) <- zip [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] l, let n = i ]


-- Border colors for unfocused and focused windows, respectively.

myNormalBorderColor  = "#2f2b26"
myFocusedBorderColor = "#2e8b57"

------------------------------------------------------------------------

-- Key bindings. Add, modify or remove key bindings here

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- close focused window
    , ((modm,               xK_q     ), kill)

    , ((modm, xK_f), sendMessage $ Toggle NBFULL)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    --, ((modm              , xK_g     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    --, ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

myLayout = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $

           --smartBorders           
           
           mkToggle (NBFULL ?? NOBORDERS ?? EOT) 
           
           tiled ||| Mirror tiled ||| Grid ||| noBorders Full

     where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
   -- , [isFullscreen --> (doF W.focusDown <+> doFullFloat)]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [className =? c --> doShift (myWorkspaces !! 0) <+> viewShift (myWorkspaces !! 0)        | c <- my1Shifts]
    , [className =? c --> doShift (myWorkspaces !! 1) <+> viewShift (myWorkspaces !! 1)        | c <- my2Shifts]
    , [className =? c --> doShift (myWorkspaces !! 2) <+> viewShift (myWorkspaces !! 2)        | c <- my3Shifts]
    , [className =? c --> doShift (myWorkspaces !! 3) <+> viewShift (myWorkspaces !! 3)        | c <- my4Shifts]
    , [className =? c --> doShift (myWorkspaces !! 4) <+> viewShift (myWorkspaces !! 4)        | c <- my5Shifts] 
    , [className =? c --> doShift (myWorkspaces !! 5) <+> viewShift (myWorkspaces !! 5)        | c <- my6Shifts]
    , [className =? c --> doShift (myWorkspaces !! 6) <+> viewShift (myWorkspaces !! 6)        | c <- my7Shifts]
    , [className =? c --> doShift (myWorkspaces !! 7) <+> viewShift (myWorkspaces !! 7)        | c <- my8Shifts]
    , [className =? c --> doShift (myWorkspaces !! 8) <+> viewShift (myWorkspaces !! 8)        | c <- my9Shifts]
    , [className =? c --> doShift (myWorkspaces !! 9) <+> viewShift (myWorkspaces !! 9)        | c <- my10Shifts]
       ]
    where
    viewShift    = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["sxiv", "Pavucontrol", "URxvt", "feh", "mpv"]
    myTFloats = ["Downloads", "Save As..."]
    myRFloats = []
    myIgnores = ["desktop_window"]
    my1Shifts = ["Brave-browser", "Vivaldi-stable", "Firefox"]
    my2Shifts = ["discord"]
    my3Shifts = ["Subl3", "subl3"]
    my4Shifts = ["discord"]
    my5Shifts = ["Gimp"]
    my6Shifts = ["vlc", "mpv"]
    my7Shifts = ["Virtualbox"]
    my8Shifts = ["Pcmanfm"]
    my9Shifts = ["viber"]
    my10Shifts = ["spotify"]


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = fullscreenEventHook <+> docksEventHook <+> minimizeEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Command to launch the bar.
myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#2e8b57" "" . wrap "["  "]" }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad =<< statusBar myBar myPP toggleStrutsKey defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.

--defaults :: XConfig ((->) (l a)) 
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
