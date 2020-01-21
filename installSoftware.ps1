<# SOFTWARE INSTALLATION SCRIPT
This script installs the appropriate software on a new machine based on its name. 
Date: 11/22/2019
Author: Marshall Amey
#>

$compName = $env:COMPUTERNAME

# Perform basic install
Write-Output "Installing Chrome..."
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\chrome\77.0.3865.90.msi'
Write-Output "Installing Firefox..."
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\firefox\69.0.2.msi'
Write-Output "Installing Slack..."
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\slack\4.1.0.0.msi /qn /norestart'
Write-Output "Installing Zoom..."
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\zoom\4.5.5422.0930.msi'
Write-Output "Installing AnyDesk..."
\\bfd\msg\it\installers\anydesk\anydesk.exe --install "C:\Program Files (x86)\AnyDesk-5be69332" --start-with-win --silent --create-shortcuts --create-desktop-icon | Out-Null
timeout /t 2
\\bfd\msg\it\deploy\scripts\anydeskConfig.bat
Add-Content C:\ProgramData\AnyDesk\ad_5be69332\system.conf "ad.anynet.alias=${compName}@ad"

Write-Output "Installing Splunk"
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\splunk\splunkforwarder-7.3.1-bd63e13aa157-x64-release.msi AGREETOLICENSE=yes SPLUNKUSERNAME=admin SPLUNKPASSWORD=Obscur@9 /quiet'
Write-Output "Copying configs to Program Files"
robocopy \\bfd\msg\it\installers\splunk\msg_all_deploymentclient "C:\\Program Files\\SplunkUniversalForwarder\\etc\\apps\\msg_all_deploymentclient" /COPYALL /E
Write-Output "Restarting Splunk Forwarder Service..."
net stop "SplunkForwarder Service"
net start "SplunkForwarder Service"

if ( $compName -like "OD-*" ) {

    Write-Output "PERFORMING STITCHING INSTALLATION"
    Write-Output "Configuring DELL machine..."
    Write-Output "Installing Chipset Driver..."
    \\bfd\msg\it\deploy\dell\Chipset_Driver_DJT82_WN32_1932.12.0.1298_A04.exe /s /i | Out-Null
    Write-Output "Installing something else..."
    \\bfd\msg\it\deploy\dell\7X20T_2.4.1.exe /s | Out-Null
    Write-Output "Installing RAID controller..."
    \\bfd\msg\it\deploy\dell\Intel-Rapid-Storage-Technology-enterprise-Driver_2206F_WIN_5.5.4.1037_A09_03.EXE /s /i | Out-Null
    Write-Output "Installing NVIDIA driver..."
    \\bfd\msg\it\deploy\dell\nVIDIA-Quadro-Graphics-Driver_NHJN7_WIN_26.21.14.3140_A00.exe /s /i | Out-Null
    Write-Output "Installing Chipset Device Software Driver..."
    \\bfd\msg\it\deploy\dell\Intel-Chipset-Device-Software-Driver_7FVVD_WIN_10.1.17861.8101_A06.exe /s /i | Out-Null

    Write-Output "Installing Deadline"
    \\bfd\msg\it\installers\thinkbox\deadline_10.0.21.5\Install_Deadline_10.0.21.5.bat

    Write-Output "Installing After Effects & Plugins"
    \\bfd\msg\it\installers\adobe\AE_15.1.2_MediaEncoder_12.1.2\AE_15.1.2_MediaEncoder_12.1.2_silent_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\redgiant\Install_ALL_RedGiant_Complete_2019_Artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\videocopilot\AE_OpticalFlares_1.3.5_and_Saber_1.0.39_Installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\revision\AE_rsmb_5.1.8_and_twixtor_6.1.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\ft_uvpass\ae_ftuvpass_5.5.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\neatvideo\AE_neatvideo_denoiser.v4_artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\7thsense\AE_7thSense_plugin_installer.bat
    
    Write-Output "Installing Nuke & Plugins"
    \\bfd\msg\it\installers\nuke\nuke11.3v2_64bit_and_caravr2.1v4_and_7thsense.v1.1_silent_installer.bat
    \\bfd\msg\it\installers\nuke\nuke_plugins\video_copilot\OpticalFlares_Nuke_11.3_Node-Locked_1.0.86\OpticalFlares_Plugin_Nuke_SILENT_INSTALLER.bat
    Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\neatvideo\NeatVideoOFX_5.0_studio\silent\NeatVideo_OFX_v5.0.0.msi'
    
    Write-Output "Installing Quicktime"
    \\bfd\msg\it\installers\quicktime\Quicktime_7_7_9_Silent_Installer.cmd
    Write-Output "Installing Hap Codec"
    \\bfd\msg\it\installers\hapq_codec\HAP_Silent_Installer.cmd
    Write-Output "Installing Houdini..."
    \\bfd\msg\it\installers\houdini\houdini-17.5.425-win64-vc141_silent_installer.bat

    Write-Output "Installing FFmpeg..."
    \\bfd\msg\it\installers\ffmpeg\ffmpeg_4.2.1_silent_installer.bat

    Write-Output "Installing VLC..."
    \\bfd\msg\it\installers\vlc\vlc-3.0.8-win64_silent_installer.bat

    Write-Output "Installing Notepad++..."
    \\bfd\msg\it\installers\npp\npp.7.8.2.Installer.x64_silent_installer.bat

    Write-Output "Installing PTGui..."
    \\bfd\msg\it\installers\ptgui\PTGui_Pro_11.18_Setup.exe /S /D=C:\Program Files\PTGui | Out-Null

} elseif ( $compName -like "MSG-MEDIA-VFX*" ) {

    Write-Output "Performing VFX artist install"

    Write-Output "Installing Deadline"
    \\bfd\msg\it\installers\thinkbox\deadline_10.0.21.5\Install_Deadline_10.0.21.5.bat

    Write-Output "Installing After Effects & Plugins"
    \\bfd\msg\it\installers\adobe\AE_15.1.2_MediaEncoder_12.1.2\AE_15.1.2_MediaEncoder_12.1.2_silent_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\redgiant\Install_ALL_RedGiant_Complete_2019_Artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\videocopilot\AE_OpticalFlares_1.3.5_and_Saber_1.0.39_Installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\revision\AE_rsmb_5.1.8_and_twixtor_6.1.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\ft_uvpass\ae_ftuvpass_5.5.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\neatvideo\AE_neatvideo_denoiser.v4_artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\7thsense\AE_7thSense_plugin_installer.bat

    Write-Output "Installing C4D & Octane"
    \\bfd\msg\it\installers\maxon\windows\C4D_R20.059_and_Deadline10.0_Submitter.bat
    \\bfd\msg\it\installers\maxon\windows\Octane.V4.02.1-R3_for_C4D.R20.059_and_Standalone.v4.02.1.bat
    \\bfd\msg\it\installers\maxon\windows\X-Particles_4.0.0642_to_c4dPref_C4D.R20.bat

    Write-Output "Installing Nuke & Plugins"
    \\bfd\msg\it\installers\nuke\nuke11.3v2_64bit_and_caravr2.1v4_and_7thsense.v1.1_silent_installer.bat
    \\bfd\msg\it\installers\nuke\nuke_plugins\video_copilot\OpticalFlares_Nuke_11.3_Node-Locked_1.0.86\OpticalFlares_Plugin_Nuke_SILENT_INSTALLER.bat
    Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\neatvideo\NeatVideoOFX_5.0_studio\silent\NeatVideo_OFX_v5.0.0.msi'

    Write-Output "Installing Quicktime"
    \\bfd\msg\it\installers\quicktime\Quicktime_7_7_9_Silent_Installer.cmd
    Write-Output "Installing Hap Codec"
    \\bfd\msg\it\installers\hapq_codec\HAP_Silent_Installer.cmd
    Write-Output "Installing Houdini..."
    \\bfd\msg\it\installers\houdini\houdini-17.5.425-win64-vc141_silent_installer.bat

    Write-Output "Installing FFmpeg..."
    \\bfd\msg\it\installers\ffmpeg\ffmpeg_4.2.1_silent_installer.bat
    
    Write-Output "Installing VLC..."
    \\bfd\msg\it\installers\vlc\vlc-3.0.8-win64_silent_installer.bat

    Write-Output "Installing Notepad++..."
    \\bfd\msg\it\installers\npp\npp.7.8.2.Installer.x64_silent_installer.bat

    Write-Output "Installing PTGui..."
    \\bfd\msg\it\installers\ptgui\PTGui_Pro_11.18_Setup.exe /S /D=C:\Program Files\PTGui | Out-Null

} elseif ( $compName -like "MSG-ENG*" ) { 

    Write-Output "Performing engineering install" 

    Write-Output "Installing Touch Designer" 
    \\bfd\msg\it\installers\touch_designer\TouchDesigner099.2019.19160.exe /passive | Out-Null
    Write-Output "Installing Notch" 
    \\bfd\msg\it\installers\notch\notch_x64_0923_rc65.exe | Out-Null

} elseif ( $compName -like "ODRN*" ) { 

    Write-Output "Performing render node install"

    Write-Output "Installing Deadline"
    \\bfd\msg\it\installers\thinkbox\deadline_10.0.21.5\Install_Deadline_10.0.21.5.bat 

    Write-Output "Installing After Effects & Plugins"
    \\bfd\msg\it\installers\adobe\AE_15.1.2_MediaEncoder_12.1.2\AE_15.1.2_MediaEncoder_12.1.2_silent_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\redgiant\Install_ALL_RedGiant_Complete_2019_Artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\videocopilot\AE_OpticalFlares_1.3.5_and_Saber_1.0.39_Installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\revision\AE_rsmb_5.1.8_and_twixtor_6.1.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\ft_uvpass\ae_ftuvpass_5.5.0_installer.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\neatvideo\AE_neatvideo_denoiser.v4_artist.bat
    \\bfd\msg\it\installers\adobe\ae_plugins\7thsense\AE_7thSense_plugin_installer.bat

    Write-Output "Installing C4D & Octane"
    \\bfd\msg\it\installers\maxon\windows\C4D_R20.059_and_Deadline10.0_Submitter.bat
    \\bfd\msg\it\installers\maxon\windows\Octane.V4.02.1-R3_for_C4D.R20.059_and_Standalone.v4.02.1.bat
    \\bfd\msg\it\installers\maxon\windows\X-Particles_4.0.0642_to_c4dPref_C4D.R20.bat

    Write-Output "Installing Nuke & Plugins"
    \\bfd\msg\it\installers\nuke\nuke11.3v2_64bit_and_caravr2.1v4_and_7thsense.v1.1_silent_installer.bat
    \\bfd\msg\it\installers\nuke\nuke_plugins\video_copilot\OpticalFlares_Nuke_11.3_Node-Locked_1.0.86\OpticalFlares_Plugin_Nuke_SILENT_INSTALLER.bat
    \\bfd\msg\it\installers\neatvideo\NeatVideoOFX_5.0_studio\silent

    Write-Output "Installing Quicktime"
    \\bfd\msg\it\installers\quicktime\Quicktime_7_7_9_Silent_Installer.cmd
    Write-Output "Installing Hap Codec"
    \\bfd\msg\it\installers\hapq_codec\HAP_Silent_Installer.cmd
    Write-Output "Installing Houdini..."
    \\bfd\msg\it\installers\houdini\houdini-17.5.425-win64-vc141_silent_installer.bat

    Write-Output "Installing FFmpeg..."
    \\bfd\msg\it\installers\ffmpeg\ffmpeg_4.2.1_silent_installer.bat

    Write-Output "Installing PTGui..."
    \\bfd\msg\it\installers\ptgui\PTGui_Pro_11.18_Setup.exe /S /D=C:\Program Files\PTGui | Out-Null

} else { 

    Write-Output "Cannot recognize computer name.  Make sure this machine has the proper naming convention" 

}

# Perform security install
Write-Output "Installing Tenable Nessus Agent"
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\nessus\NessusAgent-7.4.3-x64.msi NESSUS_GROUPS=Workstations NESSUS_SERVER=cloud.tenable.com NESSUS_KEY=8f5a88c93059845448076e1a41b582bbebc3652b5559872de725ad60c42efe47 /L log.txt /qn'
\\bfd\msg\it\deploy\scripts\linkTenable.bat
Write-Output "Installing Carbon Black Response"
\\bfd\msg\it\installers\carbon\CarbonBlackClientSetup.exe /S | Out-Null
Write-Output "Installing Carbon Black Defense"
Start-Process msiexec.exe -Wait -ArgumentList '/i \\bfd\msg\it\installers\carbon\installer_vista_win7_win8-64-3.4.0.1070.msi COMPANY_CODE=XKQYSGGEWZE7VC!DZN2 /qn'

Write-Output "Software Installation Completed!"
pause