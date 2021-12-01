/*
SSH switch test
#CLASSPATH=./jsch-0.1.55.jar  javac SshShell.java
#CLASSPATH=.:./jsch-0.1.55.jar  java SshShell
*/
import com.jcraft.jsch.*;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

public class SshShell {

  public static void main(String args[]) {
      Channel channel = null;
      Session session = null;
      try {
          JSch jsch = new JSch();
          session=jsch.getSession("admin", "192.168.200.3", 22);
          session.setPassword("accton1234");

          session.setConfig("StrictHostKeyChecking", "no");
          session.connect(3000);
          channel=session.openChannel("shell");
          channel.setInputStream(System.in);
          channel.setOutputStream(System.out);
          channel.connect();
          BufferedReader br = new BufferedReader(new InputStreamReader(channel.getInputStream()));
          DataOutputStream cmdOut = new DataOutputStream(channel.getOutputStream());
          String line;
          
          int ch; 
          while((ch = br.read())!=-1) { 
              System.out.print((char)ch);
              
              if (Integer.valueOf('>').equals(ch)) {
                  cmdOut.writeBytes("config\r"); cmdOut.flush();
              } else if (Integer.valueOf('#').equals(ch)) {  
                  cmdOut.writeBytes("set protocols netconf\r"); cmdOut.flush();
                  cmdOut.writeBytes("exit\r"); cmdOut.flush();
                  cmdOut.writeBytes("exit\r"); cmdOut.flush();
                  break;
              }
          }

          cmdOut.close();

      } catch(Exception e) {
          System.out.println(e);
      } finally {
          System.out.println("disconnect");
          if (session!=null) {
              channel.disconnect();
              session.disconnect();
              System.out.println(channel.isConnected());
          }
      }
  }

}
