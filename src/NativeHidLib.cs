using System; using System.Runtime.InteropServices; using Microsoft.Win32; using Microsoft.Win32.SafeHandles;
public class NativeHid {
[DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] public static extern SafeFileHandle CreateFile(string p,uint a,uint s,IntPtr sec,uint c,uint f,IntPtr t);
[DllImport("hid.dll")] public static extern bool HidD_GetPreparsedData(SafeFileHandle h,out IntPtr p);
[DllImport("hid.dll")] public static extern bool HidD_FreePreparsedData(IntPtr p);
[DllImport("hid.dll")] public static extern int HidP_GetCaps(IntPtr p,IntPtr caps);
public static string[] Paths() { using(var k=Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Control\DeviceClasses\{4d1e55b2-f16f-11cf-88cb-001111000030}")) { var list=new System.Collections.Generic.List<string>(); if(k==null)return list.ToArray(); foreach(var n in k.GetSubKeyNames()) if(n.ToLower().Contains("vid_1a86&pid_e310")) list.Add(@"\\?\"+n.Substring(4)); return list.ToArray(); } }
public static int[] Caps(string path) { using(var h=CreateFile(path,0,3,IntPtr.Zero,3,0,IntPtr.Zero)) { IntPtr pp; if(h.IsInvalid||!HidD_GetPreparsedData(h,out pp))return null; var b=Marshal.AllocHGlobal(64); try { if(HidP_GetCaps(pp,b)<0)return null; return new int[]{(ushort)Marshal.ReadInt16(b,0),(ushort)Marshal.ReadInt16(b,2),(ushort)Marshal.ReadInt16(b,4)}; } finally {Marshal.FreeHGlobal(b);HidD_FreePreparsedData(pp);} } }

}


