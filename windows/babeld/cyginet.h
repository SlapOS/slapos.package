/*
  Reference List in the MSDN.

  NDIS 6.0 Interfaces for Window Vista later
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff565740(v=vs.85).aspx

  NDIS Versions in Network Drivers (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff567893(v=vs.85).aspx

  For Windows XP, NDIS 5.0
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff565849(v=vs.85).aspx

  NDIS General-use Interfaces (NDIS 5.1) (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff556983(v=vs.85).aspx

  Routing Protocol Interface Functions (Windows)
  http://msdn.microsoft.com/en-us/library/windows/desktop/aa446772(v=vs.85).aspx

  Networking (Windows)
  http://msdn.microsoft.com/en-us/library/windows/desktop/ee663286(v=vs.85).aspx

  NDIS Protocol Drivers (NDIS 5.1) (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff557149(v=vs.85).aspx

  Winsock IOCTLs (Windows)
  http://msdn.microsoft.com/zh-cn/library/windows/desktop/bb736550(v=vs.85).aspx

  Creating a Basic IP Helper Application (Windows)
  http://msdn.microsoft.com/zh-cn/library/windows/desktop/aa365872(v=vs.85).aspx

  Network Awareness in Windows XP
  http://msdn.microsoft.com/en-us/library/ms700657(v=vs.85).aspx

  System-Defined Device Setup Classes (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff553419(v=vs.85).aspx

  Device Information Sets (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff541247(v=vs.85).aspx

  Accessing Device Instance SPDRP_Xxx Properties (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff537737(v=vs.85).aspx

  IOCTL_NDIS_QUERY_GLOBAL_STATS (Windows Drivers)
  http://msdn.microsoft.com/en-us/library/windows/hardware/ff548975(v=vs.85).aspx

  IPv6 RFCs and Standards Working Groups
  http://www.ipv6now.com.au/RFC.php

  Routing Table Manager Version 2
  http://msdn.microsoft.com/en-us/library/windows/desktop/bb404201(v=vs.85).aspx

  Using Routing Table Manager Version 2, this section contains sample
  code that can be used when developing clients such as routing
  protocols.
  http://msdn.microsoft.com/en-us/library/windows/desktop/aa382335(v=vs.85).aspx

  An introduction to the IPv6 protocol along with overviews on
  deployment and IPv6 transitioning technologies is available on
  Technet at Microsoft Internet Protocol Version 6 (IPv6).
  http://go.microsoft.com/fwlink/p/?linkid=194338
  http://technet.microsoft.com/en-us/network/bb530961.aspx

  Internet Protocol Version 6 (IPv6)
  http://msdn.microsoft.com/en-us//library/windows/desktop/ms738570(v=vs.85).aspx

  IPv6 Link-local and Site-local Addresses
  http://msdn.microsoft.com/zh-cn/library/windows/desktop/ms739166(v=vs.85).aspx

  Recommended Configurations for IPv6
  http://msdn.microsoft.com/en-us/library/windows/desktop/ms740117(v=vs.85).aspx

  IPv6 Support in Home Routers, It looks like a windows re6stnet.
  http://msdn.microsoft.com/en-us/windows/hardware/gg463251.aspx

  Neighbor Discovery in IPv6
  http://tools.ietf.org/html/rfc4861

  Default Address Selection for Internet Protocol version 6 (IPv6)
  http://tools.ietf.org/html/rfc3484

  Path MTU Discovery
  http://tools.ietf.org/html/rfc1191

  IPv6 Traffic Between Nodes on Different Subnets of an IPv4 Internetwork (6to4)
  http://msdn.microsoft.com/zh-cn/library/windows/desktop/ms737598(v=vs.85).aspx

  Multicast Listener Discovery (MLD)
  http://msdn.microsoft.com/en-us/library/aa916334.aspx

  IPv6 Addresses, it explains the relation between link-local address
  and interface id
  http://msdn.microsoft.com/en-us/library/aa921042.aspx

  TCP/IP (v4 and v6) Technical Reference, it shows ipv4 and ipv6 how
  to work in the windows. (Recommended)
  http://technet.microsoft.com/en-us/library/dd379473(v=ws.10).aspx
 */

#ifndef __CYGIFNET_H__
#define __CYGIFNET_H__

#ifndef IN_LOOPBACK
#define IN_LOOPBACK(a)      ((((long int) (a)) & 0xff000000) == 0x7f000000)
#endif

/* Missing defines in the Cygwin */
#define RTM_ADD		0x1	/* Add Route */
#define RTM_DELETE	0x2	/* Delete Route */
#define RTM_CHANGE	0x3	/* Change Metrics or flags */
#define RTM_GET		0x4	/* Report Metrics */

#define IFF_RUNNING      0x40
/*
 * Structure of a Link-Level sockaddr:
 */
struct sockaddr_dl {
	u_char	sdl_len;	/* Total length of sockaddr */
	u_char	sdl_family;	/* AF_LINK */
	u_short	sdl_index;	/* if != 0, system given index for interface */
	u_char	sdl_type;	/* interface type */
	u_char	sdl_nlen;	/* interface name length, no trailing 0 reqd. */
	u_char	sdl_alen;	/* link level address length */
	u_char	sdl_slen;	/* link layer selector length */
	char	sdl_data[46];	/* minimum work area, can be larger;
				   contains both if name and ll address */
};

struct cyginet_route {
    struct sockaddr_storage prefix;
    int plen;
    int metric;
    unsigned int ifindex;
    int proto;
    struct sockaddr_storage gateway;
};

#if defined(INSIDE_BABELD_CYGINET)

struct ifaddrs {
        struct ifaddrs  *ifa_next;
        char            *ifa_name;
        unsigned int     ifa_flags;
        struct sockaddr *ifa_addr;
        union {
          struct sockaddr *ifa_netmask;
          struct sockaddr *ifa_dstaddr;
        };
        void            *ifa_data;
};

struct if_nameindex {
  unsigned  if_index;
  char     *if_name;
};

typedef struct _LIBWINET_INTERFACE_MAP_TABLE {
  PCHAR     FriendlyName;
  PCHAR     AdapterName;
  BYTE      PhysicalAddress[MAX_ADAPTER_ADDRESS_LENGTH];
  DWORD     PhysicalAddressLength;
  DWORD     IfType;
  int       RouteFlags;
  DWORD     IfIndex;
  DWORD     Ipv6IfIndex;
  VOID      *next;
} LIBWINET_INTERFACE_MAP_TABLE, *PLIBWINET_INTERFACE_MAP_TABLE;

typedef struct _LIBWINET_INTERFACE {
  DWORD                              IfType;
  IF_OPER_STATUS                     OperStatus;
  DWORD                              Mtu;
  SOCKADDR                           Address;
} LIBWINET_INTERFACE, *PLIBWINET_INTERFACE;

extern unsigned             if_nametoindex (const char *);
extern char                *if_indextoname (unsigned, char *);
extern struct if_nameindex *if_nameindex (void);
extern void                 if_freenameindex (struct if_nameindex *);
extern const char          *inet_ntop (int, const void *, char *, socklen_t);
extern int                  inet_pton (int, const char *, void *);
extern int                  getifaddrs(struct ifaddrs **);
extern void                 freeifaddrs(struct ifaddrs *);

#define MALLOC(x) HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,x)
#define FREE(p)                                                 \
  if(NULL != p) {HeapFree(GetProcessHeap(),0,p); p = NULL;}
#define CLOSESOCKET(s)                                          \
  if(INVALID_SOCKET != s) {closesocket(s); s = INVALID_SOCKET;}
#define CLOSESOCKEVENT(h)                                               \
  if(WSA_INVALID_EVENT != h) {WSACloseEvent(h); h = WSA_INVALID_EVENT;}
#define SOCKETERR(e)                                                    \
  {                                                                     \
    printf("%s:%s failed: %d [%s@%d]\n",                                \
           __FUNCTION__,                                                \
           e,                                                           \
           WSAGetLastError(),                                           \
           __FILE__,                                                    \
           __LINE__                                                     \
           );                                                           \
  }

#endif  /* INSIDE_BABELD_CYGINET */

/* Export functions from cyginet */
int cyginet_startup();
void cyginet_cleanup();

int cyginet_start_monitor_route_changes(int);
int cyginet_stop_monitor_route_changes();
int cyginet_set_icmp6_redirect_accept(int);
int cyginet_set_interface_forwards(const char * ifname, int value);

int cyginet_interface_sdl(struct sockaddr_dl *, char *);
int cyginet_interface_wireless(const char *, int);
int cyginet_interface_mtu(const char *, int);
int cyginet_interface_operational(const char *, int);
int cyginet_interface_ipv4(const char *, int, unsigned char *);

int cyginet_dump_route_table(struct cyginet_route *, int);
int cyginet_loopback_index(int);

int cyginet_add_route_entry(const struct sockaddr *, unsigned short,
                            const struct sockaddr *, int , unsigned int);
int cyginet_delete_route_entry(const struct sockaddr *, unsigned short,
                               const struct sockaddr *, int , unsigned int);
int cyginet_update_route_entry(const struct sockaddr *, unsigned short,
                               const struct sockaddr *, int , unsigned int);

char * cyginet_ifname(const char *);
char * cyginet_guidname(const char *);
int cyginet_refresh_interface_table();
int cyginet_getifaddresses(char *, struct cyginet_route *, int);

#endif  /* __CYGIFNET_H__ */
