using System; using System.IO; using System.Threading; using System.Diagnostics; using System.Windows.Forms; using System.Drawing;
class LegionLGameBar {
 static string folder=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"LegionLGameBar");
 static void Log(string s){try{Directory.CreateDirectory(folder);var log=Path.Combine(folder,"Legion L status.log");if(File.Exists(log)&&new FileInfo(log).Length>1048576)File.WriteAllText(log,"");File.AppendAllText(Path.Combine(folder,"Legion L status.log"),DateTime.Now.ToString("s")+" "+s+Environment.NewLine);}catch{}}
 [STAThread] static void Main(){bool created;using(var mutex=new Mutex(true,"Local\\LegionLGameBarListener",out created)){if(!created)return; Application.EnableVisualStyles();var tray=new NotifyIcon{Icon=SystemIcons.Application,Text="Legion L → Game Bar",Visible=true};var menu=new ContextMenuStrip();menu.Items.Add("Stop Legion L mapping",null,(s,e)=>Application.Exit());tray.ContextMenuStrip=menu;new Thread(ReadLoop){IsBackground=true}.Start();Log("Listener started");Application.Run();tray.Dispose();}}
 [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)] struct Input { public uint type; public InputUnion data; }
 [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Explicit)] struct InputUnion { [System.Runtime.InteropServices.FieldOffset(0)] public KeyInput key; [System.Runtime.InteropServices.FieldOffset(0)] public MouseInput mouse; }
 [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)] struct KeyInput { public ushort vk,scan; public uint flags,time; public IntPtr extra; }
 [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)] struct MouseInput { public int x,y; public uint data,flags,time; public IntPtr extra; }
 [System.Runtime.InteropServices.DllImport("user32.dll",SetLastError=true)] static extern uint SendInput(uint count,Input[] input,int size);
 static Input Key(ushort vk,bool up){return new Input{type=1,data=new InputUnion{key=new KeyInput{vk=vk,flags=up?2u:0u}}};}
 static void OpenGameBar(){var keys=new[]{Key(0x5B,false),Key(0x47,false),Key(0x47,true),Key(0x5B,true)};uint sent=SendInput(4,keys,System.Runtime.InteropServices.Marshal.SizeOf(typeof(Input)));Log("Game Bar shortcut sent: "+sent+"/4");}
 static void ReadLoop(){while(true){try{string path=null;int size=0;foreach(var p in NativeHid.Paths()){if(!p.ToLower().Contains("mi_06"))continue;var c=NativeHid.Caps(p);if(c!=null&&c[1]==0xffa0&&c[2]>=3){path=p;size=c[2];break;}}if(path==null){Thread.Sleep(2000);continue;}using(var h=NativeHid.CreateFile(path,0x80000000,3,IntPtr.Zero,3,0,IntPtr.Zero)){if(h.IsInvalid)throw new IOException("Cannot open controller");using(var f=new FileStream(h,FileAccess.Read,size)){Log("Controller connected");var b=new byte[size];bool held=false;DateTime last=DateTime.MinValue;while(true){int n=f.Read(b,0,size);if(n<3)break;bool down=(b[1]&1)!=0;if(down&&!held&&(DateTime.UtcNow-last).TotalMilliseconds>450){last=DateTime.UtcNow;Log("Legion L pressed; opening Game Bar");try{OpenGameBar();}catch(Exception e){Log(e.Message);}}held=down;}}}}catch(Exception e){Log(e.Message);}Thread.Sleep(2000);}}
}



