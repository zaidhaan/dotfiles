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
import XMonad.Util.EZConfig
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
import XMonad.Actions.EasyMotion (selectWindow, EasyMotionConfig(..))
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
                   , Node "devtools" []
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
            , projectStartHook = Just $ do spawnOn "web" "firefox"
            }

  , Project { projectName      = "web.private"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "web.private" "firefox --private-window"
            }

  , Project { projectName      = "web.email"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "web.email" $ myTerminal ++ " neomutt"
            }

  , Project { projectName      = "conf"
            , projectDirectory = "~/.config"
            , projectStartHook = Just $ do spawnOn "conf" $ myTerminal ++ " sh -c 'GIT_DIR=~/.dotfiles zsh'"
            }

  , Project { projectName      = "media"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "media" "spotify"
            }

  , Project { projectName      = "hack"
            , projectDirectory = "~/dev/hacks"
            , projectStartHook = Just $ do spawnOn "hack" myTerminal
            }

  , Project { projectName      = "code"
            , projectDirectory = "~/dev/"
            , projectStartHook = Just $ do spawnOn "code" "code"
            }

  , Project { projectName      = "web.irc"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "web.irc" $ myTerminal ++ " -o background_opacity=0.9 weechat"
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
myEZKeys :: [(String, X())]
myEZKeys =
        [ -- terminals
          ("M-S-<Return>", spawn altTerminal)
        , ("M-C-<Return>", spawn myTerminal)
        -- hack-ish way to fire up an "incognito" terminal
        , ("M-C-\\", spawn $ myTerminal ++ " zsh -c 'export HISTFILE=\"$(date +\"/tmp/%Y-%m-%d-%H%M%S.histfile\")\" ; zsh -i ; rm $HISTFILE'")
        , ("M-C-S-<Return>", spawn $ altTerminal ++ " -o 'window.opacity=0.9'")

        -- menus
        , ("M-p", spawn "dmenu_run -i -nb '#191919' -nf '#8f8f8f' -sb '#1a687f' -sf '#dfdfdf' -fn 'terminus-9'")

        -- honestly I've forgotten what these do
        , ("M-C-S-<Right>", sendMessage $ Move R)
        , ("M-C-S-<Left>", sendMessage $ Move L)
        , ("M-C-S-<Up>", sendMessage $ Move U)
        , ("M-C-S-<Down>", sendMessage $ Move D)

        -- workspace / project navigation
        , ("M-S-w", TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView)
        , ("M-C-w", TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.shift)
        , ("M-f", switchProjectPrompt myXPConfigFuzzy)
        , ("M-S-f", shiftToProjectPrompt myXPConfigFuzzy)

        -- display manager operations
        , ("M-S-l", spawn "dm-tool lock")

        -- config editor
        , ("M-S-e", spawn "$XDG_CONFIG_HOME/xmonad/scripts/dm-confedit.sh")

        -- tree select
        , ("M-S-r", treeselectAction tsDefaultConfig)

        -- close focused window
        , ("M-S-c", kill)

         -- cycle through layouts
        , ("M-<Space>", sendMessage NextLayout)

        -- resize viewed windows to the correct size
        , ("M-n", refresh)

        -- window navigation
        , ("M-d", selectWindow def { bgCol="#022538", cancelKey=xK_Escape } >>= (`whenJust` windows . W.focusWindow))
        , ("M-S-d", selectWindow def { bgCol="#380217", cancelKey=xK_Escape } >>= (`whenJust` killWindow))

        -- window focusing
        , ("M-<Tab>", windows W.focusDown)
        , ("M-j", windows W.focusDown)
        , ("M-k", windows W.focusUp)
        , ("M-m", windows W.focusMaster)
        , ("M-<Return>", windows W.swapMaster)

        -- focused window swapping
        , ("M-S-j", windows W.swapDown)
        , ("M-S-k", windows W.swapUp)

        -- focused window resizing
        , ("M-C-h", sendMessage Shrink)
        , ("M-C-l", sendMessage Expand)
        , ("M-C-k", sendMessage MirrorExpand)
        , ("M-C-j", sendMessage MirrorShrink)

        -- jump to layout
        , ("M-C-f", sendMessage $ JumpToLayout "Full")
        , ("M-C-t", sendMessage $ JumpToLayout "Tall")
        , ("M-C-s", sendMessage $ JumpToLayout "Spiral")
        , ("M-C-b", sendMessage $ JumpToLayout "Tabbed")

        -- scratchpads
        , ("M-s", namedScratchpadAction myScratchPads "terminal")

        -- gaps
        , ("M-u", incScreenWindowSpacing (-2))
        , ("M-i", incScreenWindowSpacing (2))

        -- workspace navigation
        , ("M-l", moveTo Next (Not emptyWS))
        , ("M-h", moveTo Prev (Not emptyWS))
        , ("M-C-<Space>", toggleWS)

        -- push window back into tiling
        , ("M-t", withFocused $ windows . W.sink)

        -- control master windows count
        , ("M-,", sendMessage (IncMasterN 1))
        , ("M-.", sendMessage (IncMasterN (-1)))

        -- toggle the status bar gap
        , ("M-b", sendMessage ToggleStruts)

        -- quit xmonad
        , ("M-S-q", io (exitWith ExitSuccess))

        -- restart xmonad
        , ("M-C-q", spawn "xmonad --recompile; xmonad --restart")
        , ("M-q", spawn "xmonad --restart")

        -- show help messagae with key bindings info
        , ("M-S-/", spawn ("$XDG_CONFIG_HOME/xmonad/scripts/show-keys.sh"))

        -- move cursor to currently focused window
        , ("M-z", warpToWindow (1%2) (1%2))
        ]

-- classic key bindings
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ -- prompts
      ((modm.|. shiftMask, xK_p), submap . M.fromList $
        [ ((0, xK_m),  manPrompt myXPConfig)
        , ((0, xK_s),  kittySshPrompt myXPConfig')
        , ((0, xK_x),  xmonadPrompt myXPConfig')
        , ((0, xK_l),  layoutPrompt myXPConfig)
        ]
      )
      --  reset layouts on the current workspace to default
      , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)


    -- TODO: make use of these (e.g. for notes?)
    -- launch app (default in ~/)
    -- , ((modm, xK_g), AL.launchApp myXPConfig "code" )
    -- , ((modm, xK_g), AL.launchApp myXPConfig "firefox" )

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
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster)
    ]

-- layouts

myLayout = avoidStruts $
        named "Tall" (spacingRaw False screenBorder True windowBorder True $ ResizableTall noMasters delta masterRatio [])
    ||| named "Full" (noBorders Full)
    ||| named "Spiral" (spacingRaw False screenBorder True windowBorder True $ spiral spiralRatio)
    ||| named "Tabbed" (noBorders $ tabbed shrinkText myTabConfig)
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
availableLayouts = ["Tall", "Full", "Spiral", "Tabbed", "Combo"]

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
    xmonad $ dynamicProjects projects $ ewmh $ docks defaults
        { logHook = dynamicLogWithPP $ myPP
            { ppOutput = \x -> hPutStrLn xmproc0 x
                            >> hPutStrLn xmproc1 x
            , ppOrder  = \(ws:l:t:_)   -> [ws]
            }
        }
        `additionalKeysP`
        myEZKeys

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
