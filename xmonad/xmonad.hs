import XMonad hiding ((|||))
import Data.Monoid
import Data.Ratio
import Data.Tree
import Data.List
import Data.Char (toUpper)
import System.Exit
import System.IO (hPutStrLn)

import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Util.NamedScratchpad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WorkspaceHistory
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Spiral
import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows
import XMonad.Actions.Warp
import XMonad.Actions.Submap
import XMonad.Actions.DynamicProjects
import XMonad.Actions.SpawnOn
import qualified XMonad.Actions.TreeSelect as TS

import Zai.Xmonad.KittySsh (kittySshPrompt)
-- import XMonad.Prompt.Ssh

-- testing stuff out
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Named
import XMonad.Layout.Combo
import XMonad.Layout.WindowNavigation
import XMonad.Layout.TwoPane
import XMonad.Layout.Tabbed
-- end testing stuff out

import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Prompt.Ssh
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.XMonad
import XMonad.Prompt.Workspace ( Wor(..) )
import XMonad.Prompt.AppLauncher as AL
import Control.Arrow (first)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "kitty"
altTerminal     = "alacritty"

myFont :: String
myFont = "xft:Mononoki Nerd Font:bold:size=9:antialias=true:hinting=true"


-- whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- width of the window border in pixels.
myBorderWidth   = 1

-- mod1Mask: left alt
-- mod3Mask: right alt (supposedly?)
-- mod4Mask: super key
myModMask       = mod4Mask

altMask :: KeyMask
altMask = mod1Mask

myBrowser :: String
myBrowser = "firefox"

myEditor :: String
myEditor = "nvim"

myBar = "xmobar"
myPP = xmobarPP { ppCurrent = xmobarColor "#4378ad" "" . wrap "[" "]" }

myNormalBorderColor  = "#28303a"
myFocusedBorderColor = "#506c90"

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                ]
    where
        spawnTerm = myTerminal ++ " -T scratchpad"
        findTerm = title =? "scratchpad"
        manageTerm = customFloating $ W.RationalRect l t w h
                where
                    h = 0.9
                    w = 0.9
                    t = 0.95 -h
                    l = 0.95 -w

myWorkspaces :: Forest String
myWorkspaces = [ Node "term" []
               , Node "web"
                   [ Node "private" [] -- firefox private window
                   , Node "chat"    []
                   , Node "email"   [] -- neomutt
                   , Node "irc"   [] -- weechat
                   ]
               , Node "code" []
               , Node "media" [] -- spotify
               , Node "hack" [] -- start in ~/dev/hacks
               , Node "conf" [] -- start in ~/.config
               , Node "misc" []
               ]

-- NOTE: kinda ugly, could probably be improved later
projects :: [Project]
projects =
  [ Project { projectName      = "term"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "term" myTerminal
            }

  , Project { projectName      = "web"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "firefox"
            }

  , Project { projectName      = "web.private"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "firefox --private-window"
            }

  , Project { projectName      = "web.email"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn $ myTerminal ++ " neomutt"
            }

  , Project { projectName      = "conf"
            , projectDirectory = "~/.config"
            , projectStartHook = Just $ do spawnOn "conf" myTerminal
            }

  , Project { projectName      = "media"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "media" "spotify"
            }

  , Project { projectName      = "hack"
            , projectDirectory = "~/dev/hacks"
            , projectStartHook = Just $ do spawnOn "hack" myTerminal
            }

  , Project { projectName      = "web.irc"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn $ myTerminal ++ " weechat"
            }
  ]

treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "Qalc"         "command line calculator"          (spawn (myTerminal ++ " qalc"))) []
   , Node (TS.TSNode "Autorandr"    "load detected autorandr profile"  (spawn "autorandr -c")) []
   , Node (TS.TSNode "Pavucontrol"  "volume control"                   (spawn "pavucontrol")) []
   , Node (TS.TSNode "Nmtui"        "NetworkManager TUI"               (spawn (myTerminal ++ " nmtui"))) []
   , Node (TS.TSNode "+ Bluetooth"  "Connect to a bluetooth device"    (return ()))
       [ Node (TS.TSNode "JBL TUNE600BTNC"     "30:C0:1B:EA:25:92" (spawn "bluetoothctl connect 30:C0:1B:EA:25:92")) []
       , Node (TS.TSNode "Keychron K2"         "DC:2C:26:28:5B:1E" (spawn "bluetoothctl connect DC:2C:26:28:5B:1E"))  []
       ]
   , Node (TS.TSNode "+ Misc"       "Miscellaneous things"             (return ()))
       [ Node (TS.TSNode "Refresh OWO domains" "Update ~/.owodomains listing" (spawn "$XDG_CONFIG_HOME/xmonad/scripts/owo-refresh.sh")) []
       ]
   ]

myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    ]

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd002434
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24) -- NOTE: unchanged
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34) -- NOTE: unchanged
                              , TS.ts_highlight    = (0xffffffff, 0xff0059b3)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 25
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }

myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     -- typical emacs-like defaults
     map (first $ (,) controlMask)
     [ (xK_u, killBefore)
     , (xK_k, killAfter)
     , (xK_w, killWord Prev)
     , (xK_a, startOfLine)
     , (xK_e, endOfLine)
     , (xK_d, deleteString Next)
     , (xK_h, deleteString Prev)
     , (xK_b, moveCursor Prev)
     , (xK_f, moveCursor Next)
     , (xK_n, moveHistory W.focusUp')
     , (xK_p, moveHistory W.focusDown')
     , (xK_BackSpace, killWord Prev)
     , (xK_y, pasteString)
     , (xK_g, quit)
     , (xK_bracketleft, quit)
     , (xK_j, setSuccess True >> setDone True)
     ]
     ++
     map (first $ (,) altMask)
     [ (xK_BackSpace, killWord Prev)
     , (xK_f, moveWord Next)
     , (xK_b, moveWord Prev)
     , (xK_d, killWord Next)
     ]
     ++
     map (first $ (,) 0)
     [ (xK_Return, setSuccess True >> setDone True)
     , (xK_KP_Enter, setSuccess True >> setDone True)
     , (xK_BackSpace, deleteString Prev)
     , (xK_Delete, deleteString Next)
     , (xK_Left, moveCursor Prev)
     , (xK_Right, moveCursor Next)
     , (xK_Home, startOfLine)
     , (xK_End, endOfLine)
     , (xK_Down, moveHistory W.focusUp')
     , (xK_Up, moveHistory W.focusDown')
     , (xK_Escape, quit)
     ]

isPrefixOf' :: String -> String -> Bool
isPrefixOf' prefix str =
  isPrefixOf (map toUpper prefix) (map toUpper str)

myXPConfig :: XPConfig
myXPConfig = def
      { font                = myFont
      , bgColor             = "#282c34"
      , fgColor             = "#bbc2cf"
      , bgHLight            = "#0080ff"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , promptKeymap        = myXPKeymap
      , position            = Top
      , height              = 23
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000  -- 100000 microseconds = 0.1 sec
      , showCompletionOnTab = False
      , complCaseSensitivity = CaseInSensitive
      , searchPredicate     = isPrefixOf' -- 'fuzzyMatch' also possible
      , defaultPrompter     = id . (++ " ") . map toUpper
      , alwaysHighlight     = True
      , maxComplRows        = Nothing      -- 'Just 5' for 5 rows
      }

myXPConfig' :: XPConfig
myXPConfig' = myXPConfig
      { autoComplete        = Nothing
      }

myXPConfigFuzzy :: XPConfig
myXPConfigFuzzy = myXPConfig
      { searchPredicate = fuzzyMatch
      }

-- key bindings
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ -- terminals
      ((modm .|. shiftMask, xK_Return), spawn altTerminal)
    , ((modm .|. controlMask, xK_Return), spawn myTerminal)
    , ((modm .|. controlMask .|. shiftMask, xK_Return), spawn $ altTerminal ++ " -o 'window.opacity=0.9'")

    -- menus
    , ((modm,               xK_p     ), spawn "dmenu_run -i -nb '#191919' -nf '#8f8f8f' -sb '#1a687f' -sf '#dfdfdf' -fn 'terminus-9'")

    -- honestly I've forgotten what these do
    , ((modm .|. controlMask .|. shiftMask, xK_Right), sendMessage $ Move R)
    , ((modm .|. controlMask .|. shiftMask, xK_Left ), sendMessage $ Move L)
    , ((modm .|. controlMask .|. shiftMask, xK_Up   ), sendMessage $ Move U)
    , ((modm .|. controlMask .|. shiftMask, xK_Down ), sendMessage $ Move D)

    -- experimental
    , ((modm .|. shiftMask,   xK_w), TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView)
    , ((modm .|. controlMask, xK_w), TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.shift)
    , ((modm,                 xK_f), switchProjectPrompt myXPConfigFuzzy)
    , ((modm .|. shiftMask,   xK_f), shiftToProjectPrompt myXPConfigFuzzy)

    -- prompts
    , ((modm.|. shiftMask, xK_p), submap . M.fromList $
        [ ((0, xK_m),  manPrompt myXPConfig)
        , ((0, xK_s),  kittySshPrompt myXPConfig')
        , ((0, xK_x),  xmonadPrompt myXPConfig')
        , ((0, xK_l),  layoutPrompt myXPConfig)
        ]
      )

    -- TODO: make use of these (e.g. for notes?)
    -- launch app (default in ~/)
    -- , ((modm, xK_g), AL.launchApp myXPConfig "code" )
    -- , ((modm, xK_g), AL.launchApp myXPConfig "firefox" )

    -- display manager operations
    , ((modm .|. shiftMask, xK_l     ), spawn "dm-tool lock")

    -- config editor
    , ((modm .|. shiftMask, xK_e     ), spawn "$XDG_CONFIG_HOME/xmonad/scripts/dm-confedit.sh")

    -- tree select
    , ((modm .|. shiftMask, xK_r ), treeselectAction tsDefaultConfig)

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- cycle through layouts
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  reset layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- window focusing
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp  )
    , ((modm,               xK_m     ), windows W.focusMaster  )
    , ((modm,               xK_Return), windows W.swapMaster)

    -- focused window swapping
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- focused window resizing
    , ((modm .|. controlMask, xK_h ), sendMessage Shrink)
    , ((modm .|. controlMask, xK_l ), sendMessage Expand)
    , ((modm .|. controlMask, xK_k ), sendMessage MirrorExpand)
    , ((modm .|. controlMask, xK_j ), sendMessage MirrorShrink)

    -- jump to layout
    , ((modm .|. controlMask, xK_f), sendMessage $ JumpToLayout "Full")
    , ((modm .|. controlMask, xK_t), sendMessage $ JumpToLayout "Tall")
    , ((modm .|. controlMask, xK_s), sendMessage $ JumpToLayout "Spiral")

    -- scratchpads
    , ((modm,               xK_s  ), namedScratchpadAction myScratchPads "terminal")

    -- gaps
    , ((modm,               xK_u  ), incScreenWindowSpacing (-2))
    , ((modm,               xK_i  ), incScreenWindowSpacing (2))

    -- workspace navigation
    , ((modm,                     xK_l), moveTo Next (Not emptyWS))
    , ((modm,                     xK_h), moveTo Prev (Not emptyWS))
    , ((modm .|. controlMask, xK_space), toggleWS)

    -- push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- control master windows count
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- toggle the status bar gap
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- restart xmonad
    , ((modm .|. controlMask, xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    , ((modm                , xK_q     ), spawn "xmonad --restart")

    -- show help messagae with key bindings info
    , ((modm .|. shiftMask, xK_slash ), spawn ("$XDG_CONFIG_HOME/xmonad/scripts/show-keys.sh | dzen2"))
    --, ((modm .|. shiftMask, xK_slash ), spawn ("$XDG_CONFIG_HOME/xmonad/scripts/show-keys.sh | dzen2"))

    -- move cursor to currently focused window
    , ((modm,   xK_z     ), warpToWindow (1%2) (1%2))

    ]
    ++
    -- move mouse pointer to screen 1 or 2 {w,e}
    -- could expand to {w,e,r}
   [((modm .|. modm, key), warpToScreen sc (1%2) (1%2))
       | (key, sc) <- zip [xK_w, xK_e] [0..]]
    ++
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- mouse bindings
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    -- NOTE: mouse scroll wheel (button4 and button5) can also be binded to events
    -- mod + left click: set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
    ]

-- layouts

myLayout = avoidStruts $
        named "Tall" (spacingRaw False screenBorder True windowBorder True $ ResizableTall noMasters delta masterRatio [])
    ||| named "Full" (noBorders Full)
    ||| named "Spiral" (spacingRaw False screenBorder True windowBorder True $ spiral spiralRatio)
    ||| named "Combo" (combineTwo (TwoPane delta masterRatio) (tabbed shrinkText myTabConfig) (tabbed shrinkText myTabConfig))
        where
            noMasters = 1
            masterRatio = (1/2) -- default screen proportion occupied by master pane
            delta = (3/100) -- percentage of screen to increment when resizing panes
            gapSize = 8
            spiralRatio = (6/7)
            screenBorder = (Border gapSize 0 gapSize 0) -- <top> bottom <right> left
            windowBorder = (Border  0 gapSize 0 gapSize) -- top <bottom> right <left>
            myTabConfig = def { fontName            = "xft:Noto Sans:regular:pixelsize=11"
                              , activeColor         = "#29283e"
                              , activeBorderColor   = "#29283e"
                              , inactiveColor       = "#3f3f5e"
                              , inactiveBorderColor = "#29283e"
                              , activeTextColor     = "#ffffff"
                              , inactiveTextColor   = "#d0d0d0"
                              }

-- TODO: avoid duplication here
availableLayouts :: [String]
availableLayouts = ["Tall", "Full", "Spiral", "Combo"]

layoutPrompt :: XPConfig -> X ()
layoutPrompt c = do
  mkXPrompt (Wor "") c (mkComplFunFromList' c  (availableLayouts)) (sendMessage . JumpToLayout)

-- window rules

-- NOTE: for finding props do the following
-- $ xprop | grep WM_CLASS # or whatever

-- NOTE: for WM_NAME use 'title'
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "Xmessage"       --> doFloat
    , className =? "Dialog"         --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    ] <+> namedScratchpadManageHook myScratchPads

-- event handling
myEventHook = mempty

-- status bars and logging
-- moved to main, cause we need xmproc{0,1}

-- startup hook
myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "xbindkeys -f $XDG_CONFIG_HOME/xbindkeys/config"
    spawnOnce "picom --experimental-backends &"
    setWMName "LG3D"

-- run xmonad
main :: IO ()
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 $XDG_CONFIG_HOME/xmobar/.xmobarrc"
    xmproc1 <- spawnPipe "xmobar -x 1 $XDG_CONFIG_HOME/xmobar/.xmobarrc"
    xmonad $ dynamicProjects projects $ ewmh $ docks defaults {
        logHook = dynamicLogWithPP $ myPP {
            ppOutput = \x -> hPutStrLn xmproc0 x
                      >> hPutStrLn xmproc1 x,
            ppOrder  = \(ws:l:t:_)   -> [ws]
        }
    }

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = TS.toWorkspaces myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = return (),
        startupHook        = myStartupHook
    }
