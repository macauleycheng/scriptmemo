from ncclient import manager

# NETCONF device information
HOST = "192.168.40.131"
PORT = 8830
USER = "netconf"
PASS = "netconf"

interface="""
<config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
    <interface/>
        <interface>
           <name>Ethernet1</name>
           <type xmlns:ianaift="urn:ietf:params:xml:ns:yang:iana-if-type">ianaift:ethernetCsmacd</type>
        </interface>
    </interfaces>
</config>
"""
### IEEE 802.1AB LLDP Filter（你提供 YANG 檔案所使用的 namespace）
lldp_filter = """
<filter xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <lldp xmlns="urn:ieee:std:802.1AB:yang:ieee802-dot1ab-lldp"/>
</filter>
"""


# We enable LLDP admin-status on Ethernet1
edit_config_payload = """
<config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <lldp xmlns="urn:ieee:std:802.1AB:yang:ieee802-dot1ab-lldp"> 
    <port>
      <name>Ethernet1</name>
      <dest-mac-address>00-00-11-44-33-44</dest-mac-address>
      <admin-status>tx-and-rx</admin-status>
    </port>
  </lldp>
</config>
"""
# Filter：只撈 Ethernet1 的 LLDP 設定
get_config_filter = """
<filter xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <lldp xmlns="urn:ieee:std:802.1AB:yang:ieee802-dot1ab-lldp">
    <port>
      <name>Ethernet1</name>
    </port>  
  </lldp>
</filter>
"""

def main():

    with manager.connect(
        host=HOST,
        port=PORT,
        username=USER,
        password=PASS,
        hostkey_verify=False,
        device_params={'name': 'default'},
        allow_agent=False,
        look_for_keys=False
    ) as m:

        # Issue NETCONF <get> to read running LLDP config
        reply = m.get(lldp_filter)
        print("\n=== 1. LLDP get  ===\n")
        print(reply)

        reply = m.edit_config(
                  target="running",
                  config=interface

        # Perform <edit-config> to update running config                             )
        print("\n=== LLDP add interface ===\n")
        print(reply)

        reply = m.edit_config(
            target="running",
            config=edit_config_payload
                )        
        print("\n=== 2. LLDP edit Config ===\n")
        print(reply)

        # Issue NETCONF <get-config> to read running LLDP config
        reply = m.get_config(
                source="running",
                filter=get_config_filter
               )
        print("\n=== 3. LLDP get Config (Ethernet1) ===\n")
        print(reply)


if __name__ == "__main__":
    main()

