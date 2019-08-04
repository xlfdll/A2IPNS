package net.bi119ate5hxk.a2ipns

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.provider.Settings
import android.view.Menu
import android.widget.CompoundButton
import android.widget.Switch
import androidx.core.app.NotificationManagerCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {

    val notificationItemList = ArrayList<NotificationItem>()
    val notificationItemListAdapter = NotificationListAdapter(notificationItemList)
    val receiver = NotificationServiceReceiver()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setSupportActionBar(findViewById(R.id.actionToolbar))

        findViewById<Switch>(R.id.enableSwitch).setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                if (!isNotificationListenerEnabled(applicationContext)) {
                    openNotificationListenerSettings()
                }

                val filter = IntentFilter("net.bi119ate5hxk.a2ipns.NOTIFICATION_SERVICE")

                registerReceiver(receiver, filter)
            } else {
                unregisterReceiver(receiver)
            }
        }

        initNotificationList()
    }

    fun isNotificationListenerEnabled(context: Context): Boolean {
        return NotificationManagerCompat.getEnabledListenerPackages(this).contains(context.packageName)
    }

    fun openNotificationListenerSettings() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP_MR1) {
            startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
        } else {
            startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
        }
    }

    private fun initNotificationList() {
        findViewById<RecyclerView>(R.id.notificationRecyclerView).apply {
            setHasFixedSize(true)

            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = notificationItemListAdapter
        }
    }

    inner class NotificationServiceReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val item = intent?.getParcelableExtra<NotificationItem>("notification_item")

            if (item != null) {
                notificationItemList.add(0, item)
                notificationItemListAdapter.notifyDataSetChanged()
            }
        }
    }
}